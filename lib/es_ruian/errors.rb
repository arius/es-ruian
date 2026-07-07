# -*- encoding : utf-8 -*-
module EsRuian
  module Errors
    class Error < StandardError; end

    class InvalidAddressPlaceCodeError < Error; end
    class AddressNotFoundError < Error; end
    class MunicipalityNotDeterminableError < Error; end
    class CityUpdateNotFoundError < Error; end

    class CityUpdateFailedError < Error
      attr_reader :error_messages, :city_update

      def initialize(error_messages, city_update = nil)
        @error_messages = Array(error_messages)
        @city_update = city_update
        super(@error_messages.join(", "))
      end
    end

    class CityUpdateTimeoutError < Error; end
    class ServerError < Error; end
    class ApiError < Error; end
  end
end
