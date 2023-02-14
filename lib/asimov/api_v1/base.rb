require_relative "./api_error_translator"
require_relative "./network_error_translator"

module Asimov
  ##
  # Classes and method associated with the requests, responses, and
  # errors associated with v1 of the OpenAI API.
  ##
  module ApiV1
    ##
    # Base class for API interface implementations. Currently
    # manages the network logic for the interface.
    ##
    class Base
      extend Forwardable
      include HTTParty

      def initialize(client: nil)
        @client = client
      end
      def_delegators :@client, :headers, :request_options, :openai_api_base

      ##
      # Executes an HTTP DELETE on the specified path.
      #
      # @param [String] path the URI (when combined with the
      # openai_api_base) against which the DELETE is executed.
      ##
      def http_delete(resource:, id:)
        wrap_response_with_error_handling do
          self.class.delete(
            absolute_path("/#{resource}/#{CGI.escape(id)}"),
            { headers: headers }.merge!(request_options)
          )
        end
      end

      ##
      # Executes an HTTP GET on the specified path.
      #
      # @param [String] path the URI (when combined with the
      # openai_api_base) against which the GET is executed.
      ##
      def http_get(path:)
        wrap_response_with_error_handling do
          self.class.get(
            absolute_path(path),
            { headers: headers }.merge!(request_options)
          )
        end
      end

      ##
      # Executes an HTTP POST with JSON-encoded parameters on the specified path.
      #
      # @param [String] path the URI (when combined with the
      # openai_api_base) against which the POST is executed.
      ##
      def json_post(path:, parameters:)
        wrap_response_with_error_handling do
          self.class.post(
            absolute_path(path),
            { headers: headers,
              body: parameters&.to_json }.merge!(request_options)
          )
        end
      end

      ##
      # Executes an HTTP POST with multipart encoded parameters on the specified path.
      #
      # @param [String] path the URI (when combined with the
      # openai_api_base) against which the POST is executed.
      ##
      def multipart_post(path:, parameters: nil)
        wrap_response_with_error_handling do
          self.class.post(
            absolute_path(path),
            { headers: headers("multipart/form-data"),
              body: parameters }.merge!(request_options)
          )
        end
      end

      ##
      # Executes an HTTP GET on the specified path, streaming the resulting body
      # to the writer in case of success.
      #
      # @param [String] path the URI (when combined with the
      # openai_api_base) against which the POST is executed.
      # @param [Writer] writer an object, typically a File, that responds to a `write` method
      ##
      def http_streamed_download(path:, writer:)
        self.class.get(absolute_path(path),
                       { headers: headers,
                         stream_body: true }.merge!(request_options)) do |fragment|
          fragment.code == 200 ? writer.write(fragment) : check_for_api_error(fragment)
        end
      rescue StandardError => e
        # Any error raised by the HTTP call is a network error
        NetworkErrorTranslator.translate(e)
      end

      private

      def absolute_path(path)
        "#{openai_api_base}#{path}"
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
      end
    end
  end
end
