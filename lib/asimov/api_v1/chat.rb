require_relative "../utils/chat_messages_validator"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/chat" URI subspace.
    ##
    class Chat < Base
      RESOURCE = "chat".freeze

      ##
      # Creates a completion request with the specified parameters.
      #
      # @param [String] model the model to use for the completion
      # @param [Hash] parameters the set of parameters being passed to the API
      ##
      def create_completions(model:, messages:, parameters: {})
        raise MissingRequiredParameterError.new(:model) unless model
        raise MissingRequiredParameterError.new(:messages) unless messages
        raise StreamingResponseNotSupportedError if parameters[:stream]

        messages = Utils::ChatMessagesValidator.validate_and_normalize(messages)
        rest_create_w_json_params(resource: [RESOURCE, "completions"],
                                  parameters: parameters.merge({ model: model,
                                                                 messages: messages }))
      end
    end
  end
end
