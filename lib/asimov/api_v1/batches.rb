module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/batches" URI subspace.
    ##
    class Batches < Base
      RESOURCE = "batches".freeze
      private_constant :RESOURCE

      ##
      # Creates a batch processing job.
      #
      # @param [String] input_file_id the ID of the uploaded JSONL input file
      # @param [String] endpoint the API endpoint for batch processing
      # @param [String] completion_window the time window for completion (e.g. "24h")
      # @param [Hash] parameters additional parameters passed to the API
      # @return [Hash] the created batch object
      # @raise [Asimov::MissingRequiredParameterError] if a required parameter is missing
      ##
      def create(input_file_id:, endpoint:, completion_window:, parameters: {})
        validate_create_params(input_file_id, endpoint, completion_window)
        rest_create_w_json_params(
          resource: RESOURCE,
          parameters: parameters.merge(
            input_file_id: input_file_id,
            endpoint: endpoint,
            completion_window: completion_window
          )
        )
      end

      ##
      # Retrieves a batch by ID.
      #
      # @param [String] batch_id the ID of the batch to retrieve
      # @return [Hash] the batch object
      ##
      def retrieve(batch_id:)
        rest_get(resource: RESOURCE, id: batch_id)
      end

      ##
      # Cancels a batch that is in progress.
      #
      # @param [String] batch_id the ID of the batch to cancel
      # @return [Hash] the cancelled batch object
      ##
      def cancel(batch_id:)
        rest_create_w_json_params(
          resource: [RESOURCE, batch_id, "cancel"],
          parameters: nil
        )
      end

      ##
      # Lists batches, optionally filtered by parameters.
      #
      # @param [Hash] parameters optional query parameters (e.g. after, limit)
      # @return [Hash] a list object containing batch objects
      ##
      def list(parameters: {})
        rest_index(resource: RESOURCE, parameters: parameters)
      end

      private

      def validate_create_params(input_file_id, endpoint, completion_window)
        raise MissingRequiredParameterError.new(:input_file_id) unless input_file_id
        raise MissingRequiredParameterError.new(:endpoint) unless endpoint
        raise MissingRequiredParameterError.new(:completion_window) unless completion_window
      end
    end
  end
end
