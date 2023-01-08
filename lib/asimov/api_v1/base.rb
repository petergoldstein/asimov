require_relative "./api_error_translator"
require_relative "./network_error_translator"

module Asimov
  module ApiV1
    ##
    # Base class for API interface implementations. Currently
    # manages the network logic for the interface.
    ##
    class Base
      extend Forwardable
      include HTTParty

      base_uri "https://api.openai.com/v1"

      def initialize(client: nil)
        @client = client
      end
      def_delegators :@client, :headers, :request_options

      def http_delete(path:)
        wrap_response_with_error_handling do
          self.class.delete(
            path,
            { headers: headers }.merge!(request_options)
          )
        end
      end

      def http_get(path:)
        wrap_response_with_error_handling do
          self.class.get(
            path,
            { headers: headers }.merge!(request_options)
          )
        end
      end

      def json_post(path:, parameters:)
        wrap_response_with_error_handling do
          self.class.post(
            path,
            { headers: headers,
              body: parameters&.to_json }.merge!(request_options)
          )
        end
      end

      def multipart_post(path:, parameters: nil)
        wrap_response_with_error_handling do
          self.class.post(
            path,
            { headers: headers("multipart/form-data"),
              body: parameters }.merge!(request_options)
          )
        end
      end

      def http_streamed_download(path:, writer:)
        self.class.get(path,
                       { headers: headers,
                         stream_body: true }.merge!(request_options)) do |fragment|
          fragment.code == 200 ? writer.write(fragment) : check_for_api_error(fragment)
        end
      rescue Asimov::RequestError => e
        # Raise any translated API errors
        raise e
      rescue StandardError => e
        # Otherwise translate the error to a network error
        NetworkErrorTranslator.translate(e)
      end

      def wrap_response_with_error_handling
        resp = begin
          yield
        rescue StandardError => e
          NetworkErrorTranslator.translate(e)
        end
        check_for_api_error(resp)
        resp.parsed_response
      end

      def check_for_api_error(resp)
        return if resp.code == 200

        ApiErrorTranslator.translate(resp)
        resp
      end
    end
  end
end
