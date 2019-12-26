module Services
  module Hubspot
    class HandleWebhook
      def initialize(webhook:)
        @webhook = webhook
      end

      def call
        case @webhook['subscriptionType']
        when 'contact.propertyChange'
          return false unless webhook_valid?

          handle_webhook
        else
          false
        end
      end

      private

      def webhook_valid?
        if @webhook['propertyName'] != ENV['PROTECTED_FILE_LINK_PROPERTY'] ||
           @webhook['propertyValue'].empty?
          return false
        end

        true
      end

      def handle_webhook
        file_url = Services::Hubspot::GetUploadedFileByUrl.new(url: @webhook['propertyValue']).call
        contact = ::Hubspot::Contact.new('vid' => @webhook['objectId'], 'properties' => { sample: 'sample' })
        contact.update!(ENV['PUBLIC_FILE_LINK_PROPERTY'] => file_url)
      end
    end
  end
end
