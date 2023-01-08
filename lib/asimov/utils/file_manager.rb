require "json"

module Asimov
  module Utils
    class FileManager
      def self.open(filename)
        File.open(filename)
      rescue SystemCallError => e
        raise Asimov::FileCannotBeOpenedError.new(filename, e.message)
      end
    end
  end
end
