module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/fine-tunes" URI subspace.
    ##
    class Finetunes < Base
      URI_PREFIX = "/fine-tunes".freeze
      private_constant :URI_PREFIX

      ##
      # Lists the set of fine-tuning jobs for this API key and (optionally) organization.
      ##
      def list
        rest_index(resource: "fine-tunes")
      end

      ##
      # Creates a new fine-tuning job with the specified parameters.
      #
      # @param [String] training_file the id of the training file to use for fine tuning
      # @param [Hash] parameters the parameters passed with the fine tuning job
      ##
      def create(training_file:, parameters: {})
        raise MissingRequiredParameterError.new(:training_file) unless training_file

        json_post(path: URI_PREFIX, parameters: parameters.merge(training_file: training_file))
      end

      ##
      # Retrieves the details of a fine-tuning job with the specified id.
      #
      # @param [String] fine_tune_id the id of fine tuning job
      ##
      def retrieve(fine_tune_id:)
        rest_get(resource: "fine-tunes", id: fine_tune_id)
      end

      ##
      # Cancels the details of a fine-tuning job with the specified id.
      #
      # @param [String] fine_tune_id the id of fine tuning job
      ##
      def cancel(fine_tune_id:)
        multipart_post(path: "#{URI_PREFIX}/#{fine_tune_id}/cancel")
      end

      ##
      # Lists the events associated with a fine-tuning job with the specified id.
      #
      # @param [String] fine_tune_id the id of fine tuning job
      ##
      def list_events(fine_tune_id:)
        rest_index(resource: ["fine-tunes", fine_tune_id, "events"])
      end
    end
  end
end
