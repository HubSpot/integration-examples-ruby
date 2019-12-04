module Services
  module Hubspot
    class GetUploadedFileByUrl
      UPLOAD_FILE_PATH = 'https://api.hubapi.com/filemanager/api/v2/files'.freeze

      def initialize(path:)
        @path = path
      end

      def call
        file = get_file
        response = send_file(file)
        response['objects'].first['friendly_url']
      rescue ::Hubspot::RequestError => e
        e.response.code == 404 ? false : raise(e)
      end

      private

      def get_file
        query = Rack::Utils.parse_nested_query(@path)
        url = ::Hubspot::Connection.send(:generate_url, @path, {})
        parsed_file = HTTParty.get(url, headers: ::Hubspot::Connection.headers).body
        tempfile = Tempfile.new('fileupload')
        tempfile.binmode
        tempfile.write(parsed_file)
        tempfile.rewind

        mime_type = Mime::Type.lookup_by_extension(File.extname(query['filename'])[1..-1]).to_s
        ActionDispatch::Http::UploadedFile.new(
          tempfile: tempfile,
          filename: SecureRandom.urlsafe_base64,
          type: mime_type
        )
      end

      def send_file(file)
        options = {
          multipart:
            [
              { name: 'files', contents: file },
              { name: 'file_names', contents: SecureRandom.urlsafe_base64 }
            ]
        }

        HTTParty.post(
          UPLOAD_FILE_PATH,
          body: options,
          headers: ::Hubspot::Connection.headers.merge('Content-Type' => 'multipart/form-data')
        )
      end
    end
  end
end
