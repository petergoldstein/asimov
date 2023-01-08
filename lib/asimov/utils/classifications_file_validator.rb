require "json"

module Asimov
  module Utils
    ##
    # Validates that a file is in the "classifications" format
    # used by OpenAI.  The file is a JSONL file, with
    # "text" and "label" keys for each line that have string
    # values and an optional "metadata" key that can have
    # any value.  No other keys are permitted.
    ##
    class ClassificationsFileValidator < JsonlValidator
      def validate_line(line, idx)
        parsed = JSON.parse(line)
        validate_classification(parsed, idx)
      end

      def validate_classification(parsed, idx)
        return if classification?(parsed)

        raise InvalidClassificationError,
              "Expected file to have JSONL format with text/label and (optional) metadata keys. " \
              "Invalid format on line #{idx + 1}."
      end

      def classification?(parsed)
        return false unless parsed.is_a?(Hash)
        return false unless includes_required_key_value?("text", parsed)
        return false unless includes_required_key_value?("label", parsed)

        keys = parsed.keys
        return false unless keys.size <= 3

        keys.size == 2 ? true : keys.include?("metadata")
      end

      def includes_required_key_value?(key, parsed)
        parsed[key]&.is_a?(String)
      end
    end
  end
end
