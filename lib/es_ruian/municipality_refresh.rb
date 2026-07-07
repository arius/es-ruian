# -*- encoding : utf-8 -*-
require "json"

module EsRuian
  class MunicipalityRefresh
    ADDRESS_CODE_PATTERN = /\A\d+\z/.freeze
    SUCCESS_HTTP_CODES = [200, 202].freeze
    SERVER_ERROR_HTTP_CODES = (500..599).freeze

    class << self
      def start_municipality_refresh(address_place_code)
        new.start_municipality_refresh(address_place_code)
      end

      def fetch_city_update_status(city_update_id)
        new.fetch_city_update_status(city_update_id)
      end

      def wait_for_city_update!(city_update_id, timeout: nil, interval: nil)
        new.wait_for_city_update!(city_update_id, timeout: timeout, interval: interval)
      end

      def refresh_by_address_code!(address_place_code, poll: true, fetch_address: false)
        new.refresh_by_address_code!(address_place_code, poll: poll, fetch_address: fetch_address)
      end

      def fetch_address(address_place_code)
        new.fetch_address(address_place_code)
      end
    end

    def initialize(base_url: nil, poll_interval: nil, timeout: nil)
      @base_url = (base_url || Configuration.api_url).to_s.chomp("/")
      @poll_interval = poll_interval || Configuration.refresh_poll_interval_seconds
      @default_timeout = timeout || Configuration.refresh_timeout_seconds
    end

    def start_municipality_refresh(address_place_code)
      code = validate_address_place_code!(address_place_code)
      response = request(:post, "/city_updates/by_address_code/#{code}", not_found_error: Errors::AddressNotFoundError)
      city_update_id = response.dig("data", "city_update_id")

      raise Errors::ApiError, "Missing city_update_id in response" unless city_update_id

      city_update_id
    end

    def fetch_city_update_status(city_update_id)
      response = request(:get, "/city_updates/#{city_update_id}", not_found_error: Errors::CityUpdateNotFoundError)
      response["data"]
    end

    def wait_for_city_update!(city_update_id, timeout: nil, interval: nil)
      timeout ||= @default_timeout
      interval ||= @poll_interval
      deadline = monotonic_time + timeout

      loop do
        status = fetch_city_update_status(city_update_id)
        return status if status["finished"]

        if monotonic_time >= deadline
          raise Errors::CityUpdateTimeoutError,
                "City update #{city_update_id} did not finish within #{timeout} seconds"
        end

        sleep interval
      end
    end

    def refresh_by_address_code!(address_place_code, poll: true, fetch_address: false)
      code = validate_address_place_code!(address_place_code)
      response = request(:post, "/city_updates/by_address_code/#{code}", not_found_error: Errors::AddressNotFoundError)
      data = response["data"]
      city_update_id = data["city_update_id"]

      raise Errors::ApiError, "Missing city_update_id in response" unless city_update_id

      result = poll ? wait_for_city_update!(city_update_id) : data

      case result["status"]
      when "failed"
        raise Errors::CityUpdateFailedError.new(result["error_messages"], result)
      when "completed"
        fetch_address ? { city_update: result, address: self.class.fetch_address(code) } : result
      else
        result
      end
    end

    def fetch_address(address_place_code)
      validate_address_place_code!(address_place_code)
      AddressPlace.by_code(address_place_code)
    end

    private

    def validate_address_place_code!(code)
      code_str = code.to_s
      unless ADDRESS_CODE_PATTERN.match?(code_str)
        raise Errors::InvalidAddressPlaceCodeError, "Invalid address place code: #{code.inspect}"
      end

      code_str
    end

    # City update API vrací 202/200 a jiný tvar JSON než JSON:API endpointy v Connectoru.
    def request(method, path, not_found_error:, retries: 3)
      url = "#{@base_url}#{path}"
      attempt = 0

      loop do
        attempt += 1
        begin
          return perform_request(method, url, not_found_error)
        rescue Errors::ServerError
          raise if attempt > retries

          sleep(2**attempt)
        end
      end
    end

    def perform_request(method, url, not_found_error)
      curl = case method
             when :post
               Curl.post(url) do |request|
                 request.headers["Accept"] = "application/json"
               end
             when :get
               Curl.get(url) do |request|
                 request.headers["Accept"] = "application/json"
               end
             else
               raise ArgumentError, "Unsupported HTTP method: #{method}"
             end

      handle_response(curl, not_found_error)
      parse_successful_response(curl)
    ensure
      close_curl(curl) if curl
    end

    def handle_response(curl, not_found_error)
      status_code = curl.response_code

      if SUCCESS_HTTP_CODES.include?(status_code)
        curl
      elsif status_code == 400
        raise Errors::InvalidAddressPlaceCodeError, parse_error_body(curl)
      elsif status_code == 404
        raise not_found_error, parse_error_body(curl)
      elsif status_code == 422
        raise Errors::MunicipalityNotDeterminableError, parse_error_body(curl)
      elsif SERVER_ERROR_HTTP_CODES.include?(status_code)
        raise Errors::ServerError, parse_error_body(curl)
      else
        raise Errors::ApiError, "Unexpected HTTP #{status_code}: #{curl.body}"
      end
    end

    def parse_successful_response(curl)
      JSON.parse(curl.body)
    rescue JSON::ParserError => e
      raise Errors::ApiError, "Invalid JSON response: #{e.message}"
    end

    def parse_error_body(curl)
      body = JSON.parse(curl.body)
      body["error"] || body.to_s
    rescue JSON::ParserError
      error_body = curl.body.to_s
      error_body.empty? ? "HTTP #{curl.response_code}" : error_body
    end

    def close_curl(curl)
      curl.try(:close)
    end

    def monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
