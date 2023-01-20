require "json"

module Asimov
  module Utils
    ##
    # Validates that a file is in the "answers" or "search" format
    # used by OpenAI.  The file is a JSONL file, with
    # a "text" key for each line that has a string
    # value and an optional "metadata" key that can have
    # any value.  No other keys are permitted.
    ##
    class TextEntryFileValidator < JsonlValidator
      private

      def validate_line(line, idx)
        parsed = JSON.parse(line)
        validate_text_entry(parsed, idx)
      end

      def validate_text_entry(parsed, idx)
        return if text_entry?(parsed)

        raise InvalidTextEntryError,
              "Expected file to have the JSONL format with 'text' key and (optional) " \
              "'metadata' key. Invalid format on line #{idx + 1}."
      end

      def text_entry?(parsed)
        return false unless parsed.is_a?(Hash)

        keys = parsed.keys
        return false unless keys.size >= 1 && keys.size <= 2
        return false unless keys.include?("text")
        return false unless parsed["text"].is_a?(String)

        keys.size == 1 ? true : keys.include?("metadata")
      end
    end
  end
end
