module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/conversations" URI subspace.
    ##
    class Conversations < Base
      RESOURCE = "conversations".freeze
      private_constant :RESOURCE

      ##
      # Creates a new conversation.
      #
      # @param [Hash] parameters optional parameters for the conversation
      # @return [Hash] the created conversation object
      ##
      def create(parameters: {})
        rest_create_w_json_params(resource: RESOURCE, parameters: parameters)
      end

      ##
      # Lists conversations, optionally filtered by parameters.
      #
      # @param [Hash] parameters optional query parameters (e.g. after, limit)
      # @return [Hash] a list object containing conversation objects
      ##
      def list(parameters: {})
        rest_index(resource: RESOURCE, parameters: parameters)
      end

      ##
      # Retrieves a conversation by ID.
      #
      # @param [String] conversation_id the ID of the conversation
      # @return [Hash] the conversation object
      ##
      def retrieve(conversation_id:)
        raise MissingRequiredParameterError.new(:conversation_id) unless conversation_id

        rest_get(resource: RESOURCE, id: conversation_id)
      end

      ##
      # Updates a conversation.
      #
      # @param [String] conversation_id the ID of the conversation to update
      # @param [Hash] parameters the fields to update (e.g. metadata)
      # @return [Hash] the updated conversation object
      ##
      def update(conversation_id:, parameters: {})
        raise MissingRequiredParameterError.new(:conversation_id) unless conversation_id

        rest_create_w_json_params(
          resource: [RESOURCE, conversation_id],
          parameters: parameters
        )
      end

      ##
      # Deletes a conversation by ID.
      #
      # @param [String] conversation_id the ID of the conversation to delete
      # @return [Hash] deletion confirmation
      ##
      def delete(conversation_id:)
        raise MissingRequiredParameterError.new(:conversation_id) unless conversation_id

        rest_delete(resource: RESOURCE, id: conversation_id)
      end

      ##
      # Creates items in a conversation.
      #
      # @param [String] conversation_id the ID of the conversation
      # @param [Array<Hash>] items the items to create
      # @param [Hash] parameters additional parameters
      # @return [Hash] the created items
      ##
      def create_items(conversation_id:, items:, parameters: {})
        raise MissingRequiredParameterError.new(:conversation_id) unless conversation_id

        rest_create_w_json_params(
          resource: [RESOURCE, conversation_id, "items"],
          parameters: { items: items }.merge(parameters)
        )
      end

      ##
      # Retrieves a single item from a conversation.
      #
      # @param [String] conversation_id the ID of the conversation
      # @param [String] item_id the ID of the item to retrieve
      # @param [Hash] parameters optional query parameters
      # @return [Hash] the item object
      ##
      def retrieve_item(conversation_id:, item_id:, parameters: {})
        raise MissingRequiredParameterError.new(:conversation_id) unless conversation_id
        raise MissingRequiredParameterError.new(:item_id) unless item_id

        rest_index(
          resource: [RESOURCE, conversation_id, "items", item_id],
          parameters: parameters
        )
      end

      ##
      # Lists items in a conversation.
      #
      # @param [String] conversation_id the ID of the conversation
      # @param [Hash] parameters optional query parameters (e.g. after, limit)
      # @return [Hash] a list object containing item objects
      ##
      def list_items(conversation_id:, parameters: {})
        raise MissingRequiredParameterError.new(:conversation_id) unless conversation_id

        rest_index(
          resource: [RESOURCE, conversation_id, "items"],
          parameters: parameters
        )
      end

      ##
      # Deletes an item from a conversation.
      #
      # @param [String] conversation_id the ID of the conversation
      # @param [String] item_id the ID of the item to delete
      # @return [Hash] deletion confirmation
      ##
      def delete_item(conversation_id:, item_id:)
        raise MissingRequiredParameterError.new(:conversation_id) unless conversation_id
        raise MissingRequiredParameterError.new(:item_id) unless item_id

        rest_delete(
          resource: resource_path(RESOURCE, conversation_id, "items"),
          id: item_id
        )
      end
    end
  end
end
