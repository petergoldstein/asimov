require_relative "../utils/chat_messages_validator"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/chat" URI subspace.
    ##
    class Chat < Base
      RESOURCE = "chat".freeze
      private_constant :RESOURCE

      ##
      # Creates a chat completion request with the specified parameters.
      # When a block is given, streams the response as parsed SSE events.
      #
      # @param [String] model the model to use for the completion
      # @param [Array<Hash>] messages the messages to use for the completion
      # @param [Hash] parameters any additional parameters being passed to the API
      ##
      def create(model:, messages:, parameters: {}, &)
        raise MissingRequiredParameterError.new(:model) unless model
        raise MissingRequiredParameterError.new(:messages) unless messages

        messages = Utils::ChatMessagesValidator.validate_and_normalize(messages)
        merged = parameters.merge({ model: model, messages: messages })

        return create_streaming(merged, &) if block_given?

        rest_create_w_json_params(resource: [RESOURCE, "completions"], parameters: merged)
      end

      private

      def create_streaming(parameters, &)
        parameters[:stream] = true
        rest_create_w_json_params_streamed(resource: [RESOURCE, "completions"],
                                           parameters: parameters, &)
      end
    end
  end
end
