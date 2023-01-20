require "json"

module Asimov
  module Utils
    ##
    # Validates that a file is a JSONL file.  Subclassed by
    # more specific file validators.
    ##
    class JsonlValidator
      ##
      # Validate that the IO object (typically a File) is properly
      # formatted.  Entry method for this class and its subclasses.
      # Required format will depend on the class.
      #
      # @param [IO] io IO object, typically a file, whose contents
      # are to be format checked.
      ##
      def validate(io)
        io.each_line.with_index { |line, idx| validate_line(line, idx) }
        true
      rescue JSON::ParserError
        raise JsonlFileCannotBeParsedError, "Expected file to have the JSONL format."
      end

      private

      def validate_line(line, idx)
        JSON.parse(line)
      rescue JSON::ParserError
        raise JsonlFileCannotBeParsedError,
              "Expected file to have the JSONL format.  Error found on line #{idx + 1}."
      end
    end
  end
end
