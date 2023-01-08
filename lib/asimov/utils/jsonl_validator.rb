require "json"

module Asimov
  module Utils
    class JsonlValidator
      def self.validate(file)
        file.each_line.with_index do |line, index|
          JSON.parse(line)
        rescue JSON::ParserError => e
          raise JsonlFileCannotBeParsedError.new(file.path,
                                                 "#{e.message} - found on line #{index + 1}")
        end
        true
      end
    end
  end
end
