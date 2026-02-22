module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/conversations" URI subspace.
    ##
    class Conversations < Base
      RESOURCE = "conversations".freeze
      private_constant :RESOURCE

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
        rest_get(resource: RESOURCE, id: conversation_id)
      end

      ##
      # Deletes a conversation by ID.
      #
      # @param [String] conversation_id the ID of the conversation to delete
      # @return [Hash] deletion confirmation
      ##
      def delete(conversation_id:)
        rest_delete(resource: RESOURCE, id: conversation_id)
      end
    end
  end
end
