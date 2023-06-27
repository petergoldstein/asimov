require_relative "api_error_translator"
require_relative "network_error_translator"

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
      # Executes a REST index for the specified resource
      #
      # @param [String] resource the pluralized resource name
      ##
      def rest_index(resource:)
        wrap_response_with_error_handling do
          self.class.get(
            absolute_path("/#{Array(resource).join('/')}"),
            { headers: headers }.merge!(request_options)
          )
        end
      end

      ##
      # Executes a REST delete on the specified resource.
      #
      # @param [String] resource the pluralized resource name
      # @param [String] id the id of the resource to delete
      ##
      def rest_delete(resource:, id:)
        wrap_response_with_error_handling do
          self.class.delete(
            absolute_path("/#{resource}/#{CGI.escape(id)}"),
            { headers: headers }.merge!(request_options)
          )
        end
      end

      ##
      # Executes a REST get on the specified resource.
      #
      # @param [String] resource the pluralized resource name
      # @param [String] id the id of the resource get
      ##
      def rest_get(resource:, id:)
        wrap_response_with_error_handling do
          self.class.get(
            absolute_path("/#{resource}/#{CGI.escape(id)}"),
            { headers: headers }.merge!(request_options)
          )
        end
      end

      ##
      # Executes a REST create with JSON-encoded parameters for the specified
      # resource.
      #
      # @param [String] resource the resource to be created.
      # @param [Hash] parameters the parameters to include with the request
      # to create the resource
      ##
      def rest_create_w_json_params(resource:, parameters:)
        wrap_response_with_error_handling do
          self.class.post(
            absolute_path("/#{Array(resource).join('/')}"),
            { headers: headers,
              body: parameters&.to_json }.merge!(request_options)
          )
        end
      end

      ##
      # Executes a REST create with multipart-encoded parameters for the specified
      # resource.
      #
      # @param [String] resource the resource to be created.
      # @param [Hash] parameters the optional parameters to include with the request
      # to create the resource
      ##
      def rest_create_w_multipart_params(resource:, parameters: nil)
        wrap_response_with_error_handling do
          self.class.post(
            absolute_path("/#{Array(resource).join('/')}"),
            { headers: headers("multipart/form-data"),
              body: parameters }.merge!(request_options)
          )
        end
      end

      ##
      # Executes an REST get on the specified path, streaming the resulting body
      # to the writer in case of success.
      #
      # @param [Array] resource the resource path elements as an array
      # @param [Writer] writer an object, typically a File, that responds to a `write` method
      ##
      def rest_get_streamed_download(resource:, writer:)
        self.class.get(absolute_path("/#{Array(resource).join('/')}"),
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
