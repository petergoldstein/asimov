module Asimov
  module ApiV1
    class VectorStores < Base
      ##
      # Mixin providing file batch operations for Vector Stores.
      ##
      module FileBatches
        ##
        # Creates a file batch for a vector store.
        #
        # @param [String] vector_store_id the ID of the vector store
        # @param [Array<String>] file_ids the IDs of files to include in the batch
        # @param [Hash] parameters additional parameters
        # @return [Hash] the created file batch object
        # @raise [Asimov::MissingRequiredParameterError] if vector_store_id or file_ids is missing
        ##
        def create_file_batch(vector_store_id:, file_ids:, parameters: {})
          raise MissingRequiredParameterError.new(:vector_store_id) unless vector_store_id
          raise MissingRequiredParameterError.new(:file_ids) unless file_ids

          rest_create_w_json_params(
            resource: [RESOURCE, vector_store_id, "file_batches"],
            parameters: parameters.merge(file_ids: file_ids)
          )
        end

        ##
        # Retrieves a file batch from a vector store.
        #
        # @param [String] vector_store_id the ID of the vector store
        # @param [String] file_batch_id the ID of the file batch
        # @return [Hash] the file batch object
        ##
        def retrieve_file_batch(vector_store_id:, file_batch_id:)
          rest_get(
            resource: resource_path(RESOURCE, vector_store_id, "file_batches"),
            id: file_batch_id
          )
        end

        ##
        # Cancels a file batch in a vector store.
        #
        # @param [String] vector_store_id the ID of the vector store
        # @param [String] file_batch_id the ID of the file batch to cancel
        # @return [Hash] the cancelled file batch object
        ##
        def cancel_file_batch(vector_store_id:, file_batch_id:)
          rest_create_w_json_params(
            resource: [RESOURCE, vector_store_id, "file_batches", file_batch_id, "cancel"],
            parameters: nil
          )
        end

        ##
        # Lists files in a file batch.
        #
        # @param [String] vector_store_id the ID of the vector store
        # @param [String] file_batch_id the ID of the file batch
        # @param [Hash] parameters optional query parameters (e.g. after, limit)
        # @return [Hash] a list object containing file objects
        ##
        def list_file_batch_files(vector_store_id:, file_batch_id:, parameters: {})
          rest_index(
            resource: [RESOURCE, vector_store_id, "file_batches", file_batch_id, "files"],
            parameters: parameters
          )
        end
      end
    end
  end
end
