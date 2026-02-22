module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/evals" URI subspace.
    ##
    class Evals < Base
      RESOURCE = "evals".freeze
      private_constant :RESOURCE

      ##
      # Creates an eval.
      #
      # @param [Hash] parameters the parameters for the eval (e.g. data_source_config,
      #   testing_criteria, name, metadata)
      # @return [Hash] the created eval object
      ##
      def create(parameters: {})
        rest_create_w_json_params(resource: RESOURCE, parameters: parameters)
      end

      ##
      # Lists evals, optionally filtered by parameters.
      #
      # @param [Hash] parameters optional query parameters (e.g. after, limit, order, order_by)
      # @return [Hash] a list object containing eval objects
      ##
      def list(parameters: {})
        rest_index(resource: RESOURCE, parameters: parameters)
      end

      ##
      # Retrieves an eval by ID.
      #
      # @param [String] eval_id the ID of the eval
      # @return [Hash] the eval object
      ##
      def retrieve(eval_id:)
        raise MissingRequiredParameterError.new(:eval_id) unless eval_id

        rest_get(resource: RESOURCE, id: eval_id)
      end

      ##
      # Updates an eval.
      #
      # @param [String] eval_id the ID of the eval to update
      # @param [Hash] parameters the parameters to update (e.g. name, metadata)
      # @return [Hash] the updated eval object
      ##
      def update(eval_id:, parameters: {})
        raise MissingRequiredParameterError.new(:eval_id) unless eval_id

        rest_create_w_json_params(
          resource: [RESOURCE, eval_id],
          parameters: parameters
        )
      end

      ##
      # Deletes an eval by ID.
      #
      # @param [String] eval_id the ID of the eval to delete
      # @return [Hash] deletion confirmation
      ##
      def delete(eval_id:)
        raise MissingRequiredParameterError.new(:eval_id) unless eval_id

        rest_delete(resource: RESOURCE, id: eval_id)
      end

      ##
      # Creates a run for an eval.
      #
      # @param [String] eval_id the ID of the eval
      # @param [Hash] parameters the parameters for the run (e.g. data_source, name, metadata)
      # @return [Hash] the created run object
      ##
      def create_run(eval_id:, parameters: {})
        raise MissingRequiredParameterError.new(:eval_id) unless eval_id

        rest_create_w_json_params(
          resource: [RESOURCE, eval_id, "runs"],
          parameters: parameters
        )
      end

      ##
      # Lists runs for an eval.
      #
      # @param [String] eval_id the ID of the eval
      # @param [Hash] parameters optional query parameters (e.g. after, limit, order, status)
      # @return [Hash] a list object containing run objects
      ##
      def list_runs(eval_id:, parameters: {})
        raise MissingRequiredParameterError.new(:eval_id) unless eval_id

        rest_index(
          resource: [RESOURCE, eval_id, "runs"],
          parameters: parameters
        )
      end

      ##
      # Retrieves a run by ID.
      #
      # @param [String] eval_id the ID of the eval
      # @param [String] run_id the ID of the run
      # @return [Hash] the run object
      ##
      def retrieve_run(eval_id:, run_id:)
        raise MissingRequiredParameterError.new(:eval_id) unless eval_id
        raise MissingRequiredParameterError.new(:run_id) unless run_id

        rest_get(
          resource: resource_path(RESOURCE, eval_id, "runs"),
          id: run_id
        )
      end

      ##
      # Cancels a run that is in progress.
      #
      # @param [String] eval_id the ID of the eval
      # @param [String] run_id the ID of the run to cancel
      # @return [Hash] the cancelled run object
      ##
      def cancel_run(eval_id:, run_id:)
        raise MissingRequiredParameterError.new(:eval_id) unless eval_id
        raise MissingRequiredParameterError.new(:run_id) unless run_id

        rest_create_w_json_params(
          resource: [RESOURCE, eval_id, "runs", run_id, "cancel"],
          parameters: nil
        )
      end

      ##
      # Deletes a run by ID.
      #
      # @param [String] eval_id the ID of the eval
      # @param [String] run_id the ID of the run to delete
      # @return [Hash] deletion confirmation
      ##
      def delete_run(eval_id:, run_id:)
        raise MissingRequiredParameterError.new(:eval_id) unless eval_id
        raise MissingRequiredParameterError.new(:run_id) unless run_id

        rest_delete(
          resource: resource_path(RESOURCE, eval_id, "runs"),
          id: run_id
        )
      end

      ##
      # Lists output items for a run.
      #
      # @param [String] eval_id the ID of the eval
      # @param [String] run_id the ID of the run
      # @param [Hash] parameters optional query parameters (e.g. after, limit, order, status)
      # @return [Hash] a list object containing output item objects
      ##
      def list_output_items(eval_id:, run_id:, parameters: {})
        raise MissingRequiredParameterError.new(:eval_id) unless eval_id
        raise MissingRequiredParameterError.new(:run_id) unless run_id

        rest_index(
          resource: [RESOURCE, eval_id, "runs", run_id, "output_items"],
          parameters: parameters
        )
      end

      ##
      # Retrieves an output item by ID.
      #
      # @param [String] eval_id the ID of the eval
      # @param [String] run_id the ID of the run
      # @param [String] output_item_id the ID of the output item
      # @return [Hash] the output item object
      ##
      def retrieve_output_item(eval_id:, run_id:, output_item_id:)
        raise MissingRequiredParameterError.new(:eval_id) unless eval_id
        raise MissingRequiredParameterError.new(:run_id) unless run_id
        raise MissingRequiredParameterError.new(:output_item_id) unless output_item_id

        rest_get(
          resource: resource_path(RESOURCE, eval_id, "runs", run_id, "output_items"),
          id: output_item_id
        )
      end
    end
  end
end
