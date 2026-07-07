# -*- encoding : utf-8 -*-
require 'singleton'

module EsRuian

  class Configuration

    include Singleton

    class << self
      attr_accessor :login, :password, :api_url, :refresh_poll_interval_seconds, :refresh_timeout_seconds

      def configure(file_path = nil)
        set_defaults
        if block_given?
          yield self
        else
          file = File.open(file_path) if file_path && File.exists?(file_path)
          env = defined?(Rails) ? Rails.env : ENV['RACK_ENV']
          config = YAML.load(file)[env]
          if config.present?
            config.each_pair do |key, value|
              send("#{key}=", value)
            end
          end
        end
      end

      def set_defaults
        @api_url = ENV.fetch("RUIAN_API_BASE_URL", "https://ruian.eurosignal.cz/api")
        @refresh_poll_interval_seconds = ENV.fetch("RUIAN_REFRESH_POLL_INTERVAL_SECONDS", "10").to_i
        @refresh_timeout_seconds = ENV.fetch("RUIAN_REFRESH_TIMEOUT_SECONDS", "1800").to_i
      end
    end
  end
end
