require_relative "../utils/chat_messages_validator"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/chat" URI subspace.
    ##
    class Chat < Base
      RESOURCE = "chat".freeze
      private_constant :RESOURCE

      ##
      # Creates a chat completion request with the specified parameters.
      # When a block is given, streams the response as parsed SSE events.
      #
      # @param [String] model the model to use for the completion
      # @param [Array<Hash>] messages the messages to use for the completion
      # @param [Hash] parameters any additional parameters being passed to the API
      ##
      def create(model:, messages:, parameters: {}, &)
        raise MissingRequiredParameterError.new(:model) unless model
        raise MissingRequiredParameterError.new(:messages) unless messages

        messages = Utils::ChatMessagesValidator.validate_and_normalize(messages)
        merged = parameters.merge({ model: model, messages: messages })

        return create_streaming(merged, &) if block_given?

        rest_create_w_json_params(resource: [RESOURCE, "completions"], parameters: merged)
      end

      ##
      # Retrieves a stored chat completion by ID.
      #
      # @param [String] completion_id the ID of the completion to retrieve
      # @return [Hash] the completion object
      ##
      def retrieve(completion_id:)
        raise MissingRequiredParameterError.new(:completion_id) unless completion_id

        rest_get(resource: "chat/completions", id: completion_id)
      end

      ##
      # Updates metadata on a stored chat completion.
      #
      # @param [String] completion_id the ID of the completion to update
      # @param [Hash] parameters the fields to update (e.g. metadata)
      # @return [Hash] the updated completion object
      ##
      def update(completion_id:, parameters: {})
        raise MissingRequiredParameterError.new(:completion_id) unless completion_id

        rest_create_w_json_params(
          resource: [RESOURCE, "completions", completion_id],
          parameters: parameters
        )
      end

      ##
      # Deletes a stored chat completion.
      #
      # @param [String] completion_id the ID of the completion to delete
      # @return [Hash] deletion confirmation
      ##
      def delete(completion_id:)
        raise MissingRequiredParameterError.new(:completion_id) unless completion_id

        rest_delete(resource: "chat/completions", id: completion_id)
      end

      ##
      # Lists stored chat completions.
      #
      # @param [Hash] parameters optional query parameters (e.g. after, limit, model, metadata)
      # @return [Hash] a list object containing completion objects
      ##
      def list(parameters: {})
        rest_index(resource: [RESOURCE, "completions"], parameters: parameters)
      end

      ##
      # Lists messages for a stored chat completion.
      #
      # @param [String] completion_id the ID of the completion
      # @param [Hash] parameters optional query parameters (e.g. after, limit)
      # @return [Hash] a list object containing message objects
      ##
      def list_messages(completion_id:, parameters: {})
        raise MissingRequiredParameterError.new(:completion_id) unless completion_id

        rest_index(
          resource: [RESOURCE, "completions", completion_id, "messages"],
          parameters: parameters
        )
      end

      private

      def create_streaming(parameters, &)
        parameters[:stream] = true
        rest_create_w_json_params_streamed(resource: [RESOURCE, "completions"],
                                           parameters: parameters, &)
      end
    end
  end
end
