module Asimov
  module ApiV1
    ##
    # Translates errors which are generated by OpenAI and provided in responses
    # to raised exceptions.  Because OpenAI doesn't currently provide any
    # error-specific codes above and beyond the HTTP return code, this matching
    # process is done by matching against message text which makes it somewhat
    # fragile.
    ##
    class ApiErrorTranslator
      ##
      # This method raises an appropriate Asimov::RequestError
      # subclass if the response corresponds to an HTTP error.
      ##
      def self.translate(resp)
        match_400(resp)
        match_401(resp)
        match_404(resp)
      end

      # rubocop:disable Naming/VariableNumber
      # rubocop:disable Metrics/MethodLength
      INVALID_API_KEY_PREFIX = "Incorrect API key provided: ".freeze
      INVALID_ORGANIZATION_PREFIX = "No such organization: ".freeze
      def self.match_401(resp)
        return unless resp.code == 401

        msg = error_message(resp)
        raise Asimov::InvalidApiKeyError, msg if msg.start_with?(INVALID_API_KEY_PREFIX)
        raise Asimov::InvalidOrganizationError, msg if msg.start_with?(INVALID_ORGANIZATION_PREFIX)

        raise Asimov::AuthorizationError
      end

      INVALID_TRAINING_EXAMPLE_PREFIX = "Expected file to have JSONL format with " \
                                        "prompt/completion keys. Missing".freeze
      ADDITIONAL_PROPERTIES_ERROR_PREFIX = "Additional properties are not allowed".freeze
      INVALID_PARAMETER_VALUE_STRING = "' is not one of [".freeze
      INVALID_PARAMETER_VALUE_PREFIX_2 = "Invalid value for ".freeze
      BELOW_MINIMUM_STRING = " is less than the minimum of ".freeze
      ABOVE_MAXIMUM_STRING = " is greater than the maximum of ".freeze
      def self.match_400(resp)
        return unless resp.code == 400

        msg = error_message(resp)

        if msg.start_with?(INVALID_TRAINING_EXAMPLE_PREFIX)
          raise Asimov::InvalidTrainingExampleError,
                msg
        end
        if msg.start_with?(ADDITIONAL_PROPERTIES_ERROR_PREFIX)
          raise Asimov::UnsupportedParameterError,
                msg
        end

        if match_invalid_parameter_value?(msg)
          raise Asimov::InvalidParameterValueError,
                msg
        end

        raise Asimov::RequestError, msg
      end

      def self.match_invalid_parameter_value?(msg)
        msg.include?(INVALID_PARAMETER_VALUE_STRING) ||
          msg.include?(BELOW_MINIMUM_STRING) ||
          msg.include?(ABOVE_MAXIMUM_STRING) ||
          msg.start_with?(INVALID_PARAMETER_VALUE_PREFIX_2)
      end

      def self.match_404(resp)
        return unless resp.code == 404

        msg = error_message(resp)
        raise Asimov::NotFoundError, msg
      end

      # rubocop:enable Naming/VariableNumber
      # rubocop:enable Metrics/MethodLength

      ##
      # Extracts the error message from the API response
      ##
      def self.error_message(resp)
        # This handles fragments which can occur in a streamed download
        pr = resp.respond_to?(:parsed_response) ? resp.parsed_response : JSON.parse(resp)
        return "" unless pr.is_a?(Hash) && pr["error"].is_a?(Hash)

        pr["error"]["message"] || ""
      end
    end
  end
end
