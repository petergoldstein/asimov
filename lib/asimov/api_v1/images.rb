require_relative "../utils/file_manager"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/images" URI subspace.
    ##
    class Images < Base
      RESOURCE = "images".freeze
      private_constant :RESOURCE

      ##
      # Creates an image using the specified prompt.
      #
      # @param [String] prompt the prompt used to create the image
      # @param [Hash] parameters additional parameters passed to the API
      ##
      def create(prompt:, parameters: {})
        raise MissingRequiredParameterError.new(:prompt) unless prompt

        rest_create_w_json_params(resource: [RESOURCE, "generations"],
                                  parameters: parameters.merge({ prompt: prompt }))
      end

      ##
      # Creates edits of the specified image based on the prompt.
      #
      # @param [String] image file name  or a File-like object of the base image
      # @param [String] prompt the prompt used to guide the edit
      # @param [Hash] parameters additional parameters passed to the API
      ##
      def create_edit(image:, prompt:, parameters: {})
        raise MissingRequiredParameterError.new(:prompt) unless prompt

        rest_create_w_multipart_params(resource: [RESOURCE, "edits"],
                                       parameters: open_files(parameters.merge({
                                                                                 image: image,
                                                                                 prompt: prompt
                                                                               })))
      end

      ##
      # Creates variations of the specified image.
      #
      # @param [String] image file name or a File-like object of the base image
      # @param [Hash] parameters additional parameters passed to the API
      # @option parameters [String] :mask mask file name or a File-like object
      ##
      def create_variation(image:, parameters: {})
        rest_create_w_multipart_params(resource: [RESOURCE, "variations"],
                                       parameters: open_files(parameters.merge({ image: image })))
      end

      private

      def open_files(parameters)
        raise MissingRequiredParameterError.new(:image) unless parameters[:image]

        parameters = parameters.merge(image: Utils::FileManager.open(parameters[:image]))
        parameters[:mask] = Utils::FileManager.open(parameters[:mask]) if parameters[:mask]
        parameters
      end
    end
  end
end
