module Asimov
  module Utils
    ##
    # Validator for OpenAI's chat message format.
    # Performs basic structural validation: messages must be an array
    # of hashes, each with a "role" key. Any role string and
    # additional keys are accepted.
    ##
    class ChatMessagesValidator
      def self.validate_and_normalize(messages)
        new.validate(messages)
      end

      def validate(messages)
        raise InvalidChatMessagesError, "Chat messages cannot be nil." if messages.nil?

        unless messages.is_a?(Array)
          raise InvalidChatMessagesError,
                "Chat messages must be an array."
        end

        messages.map do |message|
          validate_message(normalize_parsed(message))
        end
      rescue JSON::ParserError
        raise InvalidChatMessagesError, "Chat messages must be valid JSON."
      end

      def validate_message(message)
        raise InvalidChatMessagesError, "Chat messages must be hashes." unless message.is_a?(Hash)

        validate_role(message["role"])
        message
      end

      def validate_role(role)
        raise InvalidChatMessagesError, "Chat messages must have a role." if role.nil?
        return if role.is_a?(String) && !role.empty?

        raise InvalidChatMessagesError,
              "Chat message role must be a non-empty string."
      end

      def normalize_parsed(message)
        return message if message.is_a?(String)

        JSON.parse(message.respond_to?(:to_json) ? message.to_json : message)
      end
    end
  end
end
