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
      type = options.delete(:type)
      connector = Connector.new(params, options)
      connector.post(post_data, type)
    end


    def initialize(params, options={})
      build_curl(params, options)
    end


    def get
      @curl.http_get do |curl|
        curl = set_headers(curl)
      end
      parse_response
      close_curl
      return @data
    rescue Exception => e
      close_curl
      raise e
    end

    def post(post_data, type)
      hash = build_post_hash(post_data, type)

      @curl.http_post({ data: hash }) do |curl|
        curl = set_headers(curl)
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
      @curl.close
      @curl = nil
      GC.start
    end

    def set_headers(curl)
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/vnd.api+json'
      curl
    end

    def build_curl(params, options)
      @curl = Curl::Easy.new(build_url(params, options))
      @curl.http_auth_types = :basic
      @curl.username = EsRuian::Configuration.login
      @curl.password = EsRuian::Configuration.password
    end

    def build_url(params, options)
      options.merge!(expanded: 1)
      encoded_uri = URI.encode(([Configuration.api_url] + params).flatten.compact.join("/"))
      p encoded_uri
      return encoded_uri
    end

    def build_post_hash(attributes, type)
      p attributes
      hash = {
        type: type,
        attributes: attributes
      }
    end

    def parse_response
      if @curl.status == "200 OK"

        @parsed_response = ::JSON.parse @curl.body
        @data = @parsed_response["data"]

        return @data
        raise "No items found" if @data.blank?
      else
        curl_status = @curl.status
        raise curl_status
      end
    end
  end
end
