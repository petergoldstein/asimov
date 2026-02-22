module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/fine_tuning/jobs" URI subspace.
    ##
    class FineTuning < Base
      RESOURCE = "fine_tuning".freeze
      JOBS_RESOURCE = [RESOURCE, "jobs"].freeze
      private_constant :RESOURCE, :JOBS_RESOURCE

      ##
      # Creates a fine-tuning job.
      #
      # @param [String] model the base model to fine-tune
      # @param [String] training_file the ID of the uploaded training file
      # @param [Hash] parameters additional parameters (e.g. hyperparameters, suffix)
      # @return [Hash] the created fine-tuning job object
      # @raise [Asimov::MissingRequiredParameterError] if model or training_file is missing
      ##
      def create(model:, training_file:, parameters: {})
        raise MissingRequiredParameterError.new(:model) unless model
        raise MissingRequiredParameterError.new(:training_file) unless training_file

        rest_create_w_json_params(
          resource: JOBS_RESOURCE,
          parameters: parameters.merge(model: model, training_file: training_file)
        )
      end

      ##
      # Lists fine-tuning jobs, optionally filtered by parameters.
      #
      # @param [Hash] parameters optional query parameters (e.g. after, limit)
      # @return [Hash] a list object containing fine-tuning job objects
      ##
      def list(parameters: {})
        rest_index(resource: JOBS_RESOURCE, parameters: parameters)
      end

      ##
      # Retrieves a fine-tuning job by ID.
      #
      # @param [String] fine_tuning_job_id the ID of the fine-tuning job
      # @return [Hash] the fine-tuning job object
      ##
      def retrieve(fine_tuning_job_id:)
        rest_get(resource: resource_path(JOBS_RESOURCE), id: fine_tuning_job_id)
      end

      ##
      # Cancels a fine-tuning job that is in progress.
      #
      # @param [String] fine_tuning_job_id the ID of the fine-tuning job to cancel
      # @return [Hash] the cancelled fine-tuning job object
      ##
      def cancel(fine_tuning_job_id:)
        rest_create_w_json_params(
          resource: JOBS_RESOURCE + [fine_tuning_job_id, "cancel"],
          parameters: nil
        )
      end

      ##
      # Lists events for a fine-tuning job.
      #
      # @param [String] fine_tuning_job_id the ID of the fine-tuning job
      # @param [Hash] parameters optional query parameters (e.g. after, limit)
      # @return [Hash] a list object containing fine-tuning event objects
      ##
      def list_events(fine_tuning_job_id:, parameters: {})
        rest_index(
          resource: JOBS_RESOURCE + [fine_tuning_job_id, "events"],
          parameters: parameters
        )
      end

      ##
      # Lists checkpoints for a fine-tuning job.
      #
      # @param [String] fine_tuning_job_id the ID of the fine-tuning job
      # @param [Hash] parameters optional query parameters (e.g. after, limit)
      # @return [Hash] a list object containing checkpoint objects
      ##
      def list_checkpoints(fine_tuning_job_id:, parameters: {})
        rest_index(
          resource: JOBS_RESOURCE + [fine_tuning_job_id, "checkpoints"],
          parameters: parameters
        )
      end
    end
  end
end
