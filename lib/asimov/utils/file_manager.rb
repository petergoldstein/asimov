require "json"

module Asimov
  module Utils
    ##
    # File-related utility methods.
    #
    # Not intended for client use.
    ##
    class FileManager
      def self.open(filename)
        File.open(filename)
      rescue SystemCallError => e
        raise Asimov::FileCannotBeOpenedError.new(filename, e.message)
      end
    end
  end
end
