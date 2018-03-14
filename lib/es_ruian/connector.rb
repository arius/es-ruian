# -*- encoding : utf-8 -*-
require 'net/http'
require 'uri'

module EsRuian
  class Connector

    def self.get(params, options = {})
      connector = Connector.new(params, options)
      connector.get
    end

    def self.post(params, post_data, options = {})
      connector = Connector.new(params, options)
      connector.post post_data
    end

    def initialize(params, options={})
      @params = params
      @options = options
    end

    def get
      @curl = Curl.get(build_url) do |curl|
        curl.headers['Accept'] = 'application/vnd.api+json'
        curl.headers['Content-Type'] = 'application/json'
      end
      parse_response
      close_curl
      return @data
    rescue Exception => e
      close_curl
      raise e
    end

    def post(post_data)
      p post_data
      @curl = Curl.post(build_url, post_data.to_json) do |curl|
        curl.headers['Accept'] = 'application/vnd.api+json'
        curl.headers['Content-Type'] = 'application/json'
      end

      parse_response
      close_curl
      return @data
    rescue Exception => e
      close_curl
      raise e
    end

    private

    def close_curl
      @curl.try :close
      @curl = nil
      GC.start
    end

    def set_headers(curl)
      curl.headers['Accept'] = 'application/vnd.api+json'
      curl.headers['Content-Type'] = 'application/json'
      curl
    end

    def build_url
      encoded_uri = URI.encode(([Configuration.api_url] + @params).flatten.compact.join("/") + "?" + @options.to_query)
      p encoded_uri
      return encoded_uri
    end

    def parse_response
      if @curl.status == "200 OK"

        @parsed_response = ::JSON.parse @curl.body
        @data = @parsed_response["data"]

        if @data.blank?
          return @data
          raise "No items found"
        else
          @data = @data.map { |res| res["attributes"] }
          return @data
        end
      else
        curl_status = @curl.status
        raise curl_status
      end
    end
  end
end
