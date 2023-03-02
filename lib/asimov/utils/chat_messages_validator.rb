module Asimov
  module Utils
    ##
    # Validator for OpenAI's chat message format
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

        content = message["content"]
        raise InvalidChatMessagesError, "Chat messages must have content." if content.nil?

        validate_keys(message)
        message
      end

      def validate_keys(json)
        additional_keys = json.keys - %w[role content]
        return if additional_keys.empty?

        raise InvalidChatMessagesError,
              "Chat messages must not have additional keys - #{additional_keys.join(', ')}."
      end

      ALLOWED_ROLES = %w[assistant system user].freeze
      def validate_role(role)
        raise InvalidChatMessagesError, "Chat messages must have a role." if role.nil?

        return true if ALLOWED_ROLES.include?(role)

        raise InvalidChatMessagesError,
              "The value '#{role}' is not a valid role for a chat message."
      end

      def normalize_parsed(message)
        return message if message.is_a?(String)

        JSON.parse(message.respond_to?(:to_json) ? message.to_json : message)
      end
    end
  end
end
