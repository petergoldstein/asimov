require_relative "../utils/file_manager"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/images" URI subspace.
    ##
    class Images < Base
      URI_PREFIX = "/images".freeze

      def create(parameters:)
        raise MissingRequiredParameterError.new(:prompt) unless parameters[:prompt]

        json_post(path: "#{URI_PREFIX}/generations", parameters: parameters)
      end

      def create_edit(parameters:)
        raise MissingRequiredParameterError.new(:prompt) unless parameters[:prompt]

        multipart_post(path: "#{URI_PREFIX}/edits", parameters: open_files(parameters))
      end

      def create_variation(parameters:)
        multipart_post(path: "#{URI_PREFIX}/variations", parameters: open_files(parameters))
      end

      private

      def open_files(parameters)
        raise MissingRequiredParameterError.new(:image) unless parameters[:image]

        parameters = parameters.merge(image: Utils::FileManager.open(parameters[:image]))
        parameters.merge!(mask: Utils::FileManager.open(parameters[:mask])) if parameters[:mask]
        parameters
      end
    end
  end
end
