module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/uploads" URI subspace.
    # Supports resumable large file uploads.
    ##
    class Uploads < Base
      RESOURCE = "uploads".freeze
      private_constant :RESOURCE

      ##
      # Creates an upload object for a large file.
      #
      # @param [String] filename the name of the file being uploaded
      # @param [String] purpose the intended purpose (e.g. "fine-tune", "assistants")
      # @param [Integer] bytes the total number of bytes in the file
      # @param [String] mime_type the MIME type of the file
      # @param [Hash] parameters additional parameters
      # @return [Hash] the created upload object
      # @raise [Asimov::MissingRequiredParameterError] if a required parameter is missing
      ##
      def create(filename:, purpose:, bytes:, mime_type:, parameters: {})
        validate_create_params(filename, purpose, bytes, mime_type)
        rest_create_w_json_params(
          resource: RESOURCE,
          parameters: parameters.merge(
            filename: filename, purpose: purpose,
            bytes: bytes, mime_type: mime_type
          )
        )
      end

      ##
      # Adds a part to an upload.
      #
      # @param [String] upload_id the ID of the upload
      # @param [IO] data the file part data to upload
      # @return [Hash] the created upload part object
      # @raise [Asimov::MissingRequiredParameterError] if data is missing
      ##
      def add_part(upload_id:, data:)
        raise MissingRequiredParameterError.new(:data) unless data

        rest_create_w_multipart_params(
          resource: [RESOURCE, upload_id, "parts"],
          parameters: { data: data }
        )
      end

      ##
      # Completes an upload, assembling the parts into a file.
      #
      # @param [String] upload_id the ID of the upload
      # @param [Array<String>] part_ids the ordered list of part IDs
      # @param [Hash] parameters additional parameters (e.g. md5)
      # @return [Hash] the completed upload object with the assembled file
      # @raise [Asimov::MissingRequiredParameterError] if part_ids is missing
      ##
      def complete(upload_id:, part_ids:, parameters: {})
        raise MissingRequiredParameterError.new(:part_ids) unless part_ids

        rest_create_w_json_params(
          resource: [RESOURCE, upload_id, "complete"],
          parameters: parameters.merge(part_ids: part_ids)
        )
      end

      ##
      # Cancels an upload.
      #
      # @param [String] upload_id the ID of the upload to cancel
      # @return [Hash] the cancelled upload object
      ##
      def cancel(upload_id:)
        rest_create_w_json_params(
          resource: [RESOURCE, upload_id, "cancel"],
          parameters: nil
        )
      end

      private

      def validate_create_params(filename, purpose, bytes, mime_type)
        raise MissingRequiredParameterError.new(:filename) unless filename
        raise MissingRequiredParameterError.new(:purpose) unless purpose
        raise MissingRequiredParameterError.new(:bytes) unless bytes
        raise MissingRequiredParameterError.new(:mime_type) unless mime_type
      end
    end
  end
end
