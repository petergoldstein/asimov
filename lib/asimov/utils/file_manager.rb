require "json"

module Asimov
  module Utils
    ##
    # File-related utility methods.
    #
    # Not intended for client use.
    ##
    class FileManager
      ##
      # Open the file with the given filename, raising an error if the
      # file cannot be opened.
      #
      # @param [String] filename the path to the file to be opened
      ##
      def self.open(filename)
        File.open(filename)
      rescue SystemCallError => e
        raise Asimov::FileCannotBeOpenedError.new(filename, e.message)
      end
    end
  end
end
