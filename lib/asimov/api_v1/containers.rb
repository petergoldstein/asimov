require_relative "../utils/file_manager"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/containers" URI subspace.
    ##
    class Containers < Base
      RESOURCE = "containers".freeze
      private_constant :RESOURCE

      ##
      # Creates a container.
      #
      # @param [String] name the name of the container
      # @param [Hash] parameters additional parameters (e.g. expires_after, file_ids, memory_limit)
      # @return [Hash] the created container object
      # @raise [Asimov::MissingRequiredParameterError] if name is missing
      ##
      def create(name:, parameters: {})
        raise MissingRequiredParameterError.new(:name) unless name

        rest_create_w_json_params(resource: RESOURCE, parameters: parameters.merge(name: name))
      end

      ##
      # Lists containers, optionally filtered by parameters.
      #
      # @param [Hash] parameters optional query parameters (e.g. after, limit, order)
      # @return [Hash] a list object containing container objects
      ##
      def list(parameters: {})
        rest_index(resource: RESOURCE, parameters: parameters)
      end

      ##
      # Retrieves a container by ID.
      #
      # @param [String] container_id the ID of the container
      # @return [Hash] the container object
      ##
      def retrieve(container_id:)
        raise MissingRequiredParameterError.new(:container_id) unless container_id

        rest_get(resource: RESOURCE, id: container_id)
      end

      ##
      # Deletes a container by ID.
      #
      # @param [String] container_id the ID of the container to delete
      # @return [Hash] deletion confirmation
      ##
      def delete(container_id:)
        raise MissingRequiredParameterError.new(:container_id) unless container_id

        rest_delete(resource: RESOURCE, id: container_id)
      end

      ##
      # Uploads a file to a container.
      #
      # @param [String] container_id the ID of the container
      # @param [String] file file name or a File-like object to be uploaded
      # @param [Hash] parameters additional parameters
      # @return [Hash] the created container file object
      # @raise [Asimov::MissingRequiredParameterError] if file is missing
      ##
      def create_file(container_id:, file:, parameters: {})
        raise MissingRequiredParameterError.new(:container_id) unless container_id
        raise MissingRequiredParameterError.new(:file) unless file

        rest_create_w_multipart_params(
          resource: [RESOURCE, container_id, "files"],
          parameters: parameters.merge(file: Utils::FileManager.open(file))
        )
      end

      ##
      # Lists files in a container.
      #
      # @param [String] container_id the ID of the container
      # @param [Hash] parameters optional query parameters (e.g. after, limit, order)
      # @return [Hash] a list object containing container file objects
      ##
      def list_files(container_id:, parameters: {})
        raise MissingRequiredParameterError.new(:container_id) unless container_id

        rest_index(
          resource: [RESOURCE, container_id, "files"],
          parameters: parameters
        )
      end

      ##
      # Retrieves a file from a container.
      #
      # @param [String] container_id the ID of the container
      # @param [String] file_id the ID of the file to retrieve
      # @return [Hash] the container file object
      ##
      def retrieve_file(container_id:, file_id:)
        raise MissingRequiredParameterError.new(:container_id) unless container_id
        raise MissingRequiredParameterError.new(:file_id) unless file_id

        rest_get(
          resource: resource_path(RESOURCE, container_id, "files"),
          id: file_id
        )
      end

      ##
      # Deletes a file from a container.
      #
      # @param [String] container_id the ID of the container
      # @param [String] file_id the ID of the file to delete
      # @return [Hash] deletion confirmation
      ##
      def delete_file(container_id:, file_id:)
        raise MissingRequiredParameterError.new(:container_id) unless container_id
        raise MissingRequiredParameterError.new(:file_id) unless file_id

        rest_delete(
          resource: resource_path(RESOURCE, container_id, "files"),
          id: file_id
        )
      end

      ##
      # Downloads file content from a container as a streamed binary.
      #
      # @param [String] container_id the ID of the container
      # @param [String] file_id the ID of the file
      # @param [Writer] writer the Writer that will process the chunked content
      ##
      def file_content(container_id:, file_id:, writer:)
        raise MissingRequiredParameterError.new(:container_id) unless container_id
        raise MissingRequiredParameterError.new(:file_id) unless file_id

        rest_get_streamed_download(
          resource: [RESOURCE, container_id, "files", file_id, "content"],
          writer: writer
        )
      end
    end
  end
end
