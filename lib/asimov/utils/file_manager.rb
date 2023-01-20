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
      # Returns the file corresponding to the file_or_path.  If the argument is a
      # file, then just returns the argument.  Otherwise calls File.open with the
      # argument.  Raises an error if the file cannot be opened.
      #
      # @param [File/String] file_or_path the path to the file to be opened
      ##
      def self.open(file_or_path)
        file?(file_or_path) ? file_or_path : File.open(file_or_path)
      rescue SystemCallError => e
        raise Asimov::FileCannotBeOpenedError.new(file_or_path, e.message)
      end

      def self.file?(object)
        object.respond_to?(:path) && object.respond_to?(:read)
      end
      private_class_method :file?
    end
  end
end
