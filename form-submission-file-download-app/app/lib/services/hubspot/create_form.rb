module Services
  module Hubspot
    class CreateForm
      def initialize(form_name:, request:)
        @form_name = form_name
        @request = request
      end

      def call
        ::Hubspot::Form.create!(form_params)
      rescue ::Hubspot::RequestError => e
        raise(ExceptionHandler::HubspotError.new, e.message)
      end

      private

      def form_params
        [
          name: @form_name,
          submitText: 'Save',
          redirect: server_uri + '/contacts',
          formFieldGroups: form_field_groups_params
        ]
      end

      def form_field_groups_params
        property_name = ENV['PROTECTED_FILE_LINK_PROPERTY']
        [{
          fields: {
            name: 'email',
            label: 'Contacts Email',
            type: 'string',
            fieldType: 'text',
            required: true,
            placeholder: 'Email'
          },
          default: true,
          isSmartGroup: false
        }, {
          fields: {
            name: property_name,
            label: property_name,
            type: 'string',
            fieldType: 'file',
            placeholder: property_name
          },
          default: true,
          isSmartGroup: false
        }]
      end

      def server_uri
        @request.protocol + @request.host_with_port
      end
    end
  end
end
