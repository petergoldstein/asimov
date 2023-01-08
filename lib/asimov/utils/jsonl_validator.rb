require "json"

module Asimov
  module Utils
    ##
    # Validates that a file is a JSONL file.  Subclassed by
    # more specific file validators.
    ##
    class JsonlValidator
      def validate(file)
        file.each_line.with_index { |line, idx| validate_line(line, idx) }
        true
      rescue JSON::ParserError
        raise JsonlFileCannotBeParsedError, "Expected file to have the JSONL format."
      end

      def validate_line(line, idx)
        JSON.parse(line)
      rescue JSON::ParserError
        raise JsonlFileCannotBeParsedError,
              "Expected file to have the JSONL format.  Error found on line #{idx + 1}."
      end
    end
  end
end
