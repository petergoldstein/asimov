require "json"

module Asimov
  module Utils
    ##
    # Validates that a file is in the "fine-tune" format
    # used by OpenAI.  The file is a JSONL file, with
    # "prompt" and "completion" keys for each line that have string
    # values.  No other keys are permitted.
    ##
    class TrainingFileValidator < JsonlValidator
      private

      def validate_line(line, idx)
        parsed = JSON.parse(line)
        validate_training_example(parsed, idx)
      end

      def validate_training_example(parsed, idx)
        return if training_example?(parsed)

        raise InvalidTrainingExampleError,
              "Expected file to have JSONL format with prompt/completion keys. " \
              "Invalid format on line #{idx + 1}."
      end

      def training_example?(parsed)
        return false unless parsed.is_a?(Hash)

        keys = parsed.keys
        return false unless keys.size == 2
        return false unless keys.include?("prompt")
        return false unless keys.include?("completion")
        return false unless parsed["prompt"].is_a?(String)
        return false unless parsed["completion"].is_a?(String)

        true
      end
    end
  end
end
