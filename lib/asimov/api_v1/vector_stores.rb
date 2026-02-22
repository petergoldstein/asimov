require_relative "vector_stores/file_batches"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/vector_stores" URI subspace.
    ##
    class VectorStores < Base
      include FileBatches

      RESOURCE = "vector_stores".freeze
      private_constant :RESOURCE

      ##
      # Creates a vector store.
      #
      # @param [Hash] parameters the parameters for the vector store (e.g. name, file_ids)
      # @return [Hash] the created vector store object
      ##
      def create(parameters: {})
        rest_create_w_json_params(resource: RESOURCE, parameters: parameters)
      end

      ##
      # Lists vector stores, optionally filtered by parameters.
      #
      # @param [Hash] parameters optional query parameters (e.g. after, limit)
      # @return [Hash] a list object containing vector store objects
      ##
      def list(parameters: {})
        rest_index(resource: RESOURCE, parameters: parameters)
      end

      ##
      # Retrieves a vector store by ID.
      #
      # @param [String] vector_store_id the ID of the vector store
      # @return [Hash] the vector store object
      ##
      def retrieve(vector_store_id:)
        rest_get(resource: RESOURCE, id: vector_store_id)
      end

      ##
      # Updates a vector store.
      #
      # @param [String] vector_store_id the ID of the vector store to update
      # @param [Hash] parameters the parameters to update (e.g. name, metadata)
      # @return [Hash] the updated vector store object
      ##
      def update(vector_store_id:, parameters: {})
        rest_create_w_json_params(
          resource: [RESOURCE, vector_store_id],
          parameters: parameters
        )
      end

      ##
      # Deletes a vector store by ID.
      #
      # @param [String] vector_store_id the ID of the vector store to delete
      # @return [Hash] deletion confirmation
      ##
      def delete(vector_store_id:)
        rest_delete(resource: RESOURCE, id: vector_store_id)
      end

      ##
      # Searches a vector store.
      #
      # @param [String] vector_store_id the ID of the vector store to search
      # @param [String] query the search query
      # @param [Hash] parameters additional search parameters (e.g. max_num_results)
      # @return [Hash] search results
      # @raise [Asimov::MissingRequiredParameterError] if query is missing
      ##
      def search(vector_store_id:, query:, parameters: {})
        raise MissingRequiredParameterError.new(:query) unless query

        rest_create_w_json_params(
          resource: [RESOURCE, vector_store_id, "search"],
          parameters: parameters.merge(query: query)
        )
      end

      ##
      # Adds a file to a vector store.
      #
      # @param [String] vector_store_id the ID of the vector store
      # @param [String] file_id the ID of the file to add
      # @param [Hash] parameters additional parameters
      # @return [Hash] the created vector store file object
      # @raise [Asimov::MissingRequiredParameterError] if file_id is missing
      ##
      def create_file(vector_store_id:, file_id:, parameters: {})
        raise MissingRequiredParameterError.new(:file_id) unless file_id

        rest_create_w_json_params(
          resource: [RESOURCE, vector_store_id, "files"],
          parameters: parameters.merge(file_id: file_id)
        )
      end

      ##
      # Lists files in a vector store.
      #
      # @param [String] vector_store_id the ID of the vector store
      # @param [Hash] parameters optional query parameters (e.g. after, limit)
      # @return [Hash] a list object containing vector store file objects
      ##
      def list_files(vector_store_id:, parameters: {})
        rest_index(
          resource: [RESOURCE, vector_store_id, "files"],
          parameters: parameters
        )
      end

      ##
      # Retrieves a file from a vector store.
      #
      # @param [String] vector_store_id the ID of the vector store
      # @param [String] file_id the ID of the file to retrieve
      # @return [Hash] the vector store file object
      ##
      def retrieve_file(vector_store_id:, file_id:)
        rest_get(
          resource: resource_path(RESOURCE, vector_store_id, "files"),
          id: file_id
        )
      end

      ##
      # Deletes a file from a vector store.
      #
      # @param [String] vector_store_id the ID of the vector store
      # @param [String] file_id the ID of the file to delete
      # @return [Hash] deletion confirmation
      ##
      def delete_file(vector_store_id:, file_id:)
        rest_delete(
          resource: resource_path(RESOURCE, vector_store_id, "files"),
          id: file_id
        )
      end
    end
  end
end
