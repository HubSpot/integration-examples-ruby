module Services
  module Hubspot
    class GetContactProperty
      GET_PROPERTY_PATH = '/contacts/v2/properties/named/:property_name'.freeze

      def initialize(name:)
        @name = name
      end

      def call
        path = GET_PROPERTY_PATH.dup
        ::Hubspot::Connection.get_json(path, property_name: @name)
      rescue ::Hubspot::RequestError => e
        e.response.code == 404 ? false : raise(e)
      end
    end
  end
end
