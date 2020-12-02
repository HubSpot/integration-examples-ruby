module Services
  module Hubspot
    class GetUploadedFileByUrl
      def initialize(url:)
        @url = url
      end

      def call
        response = Services::Hubspot::FileUploader.upload(file)
        response['objects'].first['friendly_url']
      rescue ::Hubspot::RequestError => e
        e.response.code == 404 ? false : raise(e)
      end

      private

      attr_reader :url

      def file
        parsed_file = ::Hubspot::Form.upload_file(url)
        tempfile = file_attachment(parsed_file)

        File.open(tempfile.path)
      end

      def file_attachment(parsed_file)
        tempfile = Tempfile.new(SecureRandom.uuid)
        tempfile.binmode
        tempfile.write(parsed_file)
        tempfile.rewind
        tempfile
      end
    end
  end
end
