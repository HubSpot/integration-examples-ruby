module Services
  module Hubspot
    class GetUploadedFileByUrl
      def initialize(url:)
        @url = url
      end

      def call
        file = get_file
        response = ::Hubspot::File.upload(file, file_names: SecureRandom.urlsafe_base64)
        response['objects'].first['friendly_url']
      rescue ::Hubspot::RequestError => e
        e.response.code == 404 ? false : raise(e)
      end

      private

      def get_file
        parsed_file = ::Hubspot::Form.upload_file(@url)
        tempfile = file_attachment(parsed_file)

        query = Rack::Utils.parse_nested_query(@url)
        mime_type = Mime::Type.lookup_by_extension(File.extname(query['filename'])[1..-1]).to_s
        ActionDispatch::Http::UploadedFile.new(
          tempfile: tempfile,
          filename: SecureRandom.urlsafe_base64,
          type: mime_type
        )
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
