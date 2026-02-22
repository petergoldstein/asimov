require "event_stream_parser"

module Asimov
  module ApiV1
    ##
    # Mixin providing streaming and binary download REST primitives.
    # Included by Base to keep the class length manageable.
    ##
    module Streaming
      STREAM_DONE_MARKER = "[DONE]".freeze
      private_constant :STREAM_DONE_MARKER

      # EventStreamParser::Parser is stateless and requires no cleanup.
      def rest_create_w_json_params_streamed(resource:, parameters:, &block)
        parser = EventStreamParser::Parser.new
        post_streamed(resource: resource, parameters: parameters) do |fragment|
          handle_streamed_fragment(parser, fragment, &block)
        end
      rescue StandardError => e
        NetworkErrorTranslator.translate(e)
      end

      def rest_create_w_json_params_binary(resource:, parameters:)
        resp = wrap_raw_response_with_error_handling(resource: resource, parameters: parameters)
        check_for_api_error(resp)
        resp.body
      end

      # The writer is caller-owned; cleanup is the caller's responsibility.
      def rest_create_w_json_params_streamed_download(resource:, parameters:, writer:)
        self.class.post(
          absolute_path("/#{Array(resource).join('/')}"),
          { headers: headers,
            body: parameters&.to_json,
            stream_body: true }.merge!(request_options)
        ) do |fragment|
          fragment.code == 200 ? writer.write(fragment) : check_for_api_error(fragment)
        end
      rescue StandardError => e
        NetworkErrorTranslator.translate(e)
      end

      # The writer is caller-owned; cleanup is the caller's responsibility.
      def rest_get_streamed_download(resource:, writer:)
        self.class.get(absolute_path("/#{Array(resource).join('/')}"),
                       { headers: headers,
                         stream_body: true }.merge!(request_options)) do |fragment|
          fragment.code == 200 ? writer.write(fragment) : check_for_api_error(fragment)
        end
      rescue StandardError => e
        NetworkErrorTranslator.translate(e)
      end

      private

      def wrap_raw_response_with_error_handling(resource:, parameters:)
        self.class.post(
          absolute_path("/#{Array(resource).join('/')}"),
          { headers: headers, body: parameters&.to_json, format: :plain }.merge!(request_options)
        )
      rescue StandardError => e
        NetworkErrorTranslator.translate(e)
      end

      def post_streamed(resource:, parameters:, &)
        self.class.post(
          absolute_path("/#{Array(resource).join('/')}"),
          { headers: headers,
            body: parameters&.to_json,
            stream_body: true }.merge!(request_options),
          &
        )
      end

      def handle_streamed_fragment(parser, fragment)
        if fragment.code == 200
          parser.feed(fragment) do |_type, data, _id, _reconnection_time|
            next if done_marker?(data)

            parsed = safe_json_parse(data)
            yield parsed if parsed
          end
        else
          check_for_api_error(fragment)
        end
      end

      def done_marker?(data)
        data.strip == STREAM_DONE_MARKER
      end

      def safe_json_parse(data)
        JSON.parse(data)
      rescue JSON::ParserError
        nil
      end
    end
  end
end
