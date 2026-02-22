module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/responses" URI subspace.
    ##
    class Responses < Base
      RESOURCE = "responses".freeze
      private_constant :RESOURCE

      ##
      # Creates a response with the specified parameters.
      # When a block is given, streams the response as parsed SSE events.
      #
      # @param [String] model the model to use
      # @param [String, Array] input the input text or conversation
      # @param [Hash] parameters additional parameters
      # @return [Hash] the response object (non-streaming)
      # @yield [Hash] parsed SSE event data (streaming)
      # @raise [Asimov::MissingRequiredParameterError] if model or input is missing
      ##
      def create(model:, input:, parameters: {}, &)
        raise MissingRequiredParameterError.new(:model) unless model
        raise MissingRequiredParameterError.new(:input) unless input

        merged = parameters.merge(model: model, input: input)

        return create_streaming(merged, &) if block_given?

        rest_create_w_json_params(resource: RESOURCE, parameters: merged)
      end

      ##
      # Retrieves a response by ID.
      #
      # @param [String] response_id the ID of the response to retrieve
      # @return [Hash] the response object
      ##
      def retrieve(response_id:)
        rest_get(resource: RESOURCE, id: response_id)
      end

      ##
      # Deletes a response by ID.
      #
      # @param [String] response_id the ID of the response to delete
      # @return [Hash] deletion confirmation
      ##
      def delete(response_id:)
        rest_delete(resource: RESOURCE, id: response_id)
      end

      ##
      # Lists input items for a response.
      #
      # @param [String] response_id the ID of the response
      # @param [Hash] parameters optional query parameters (e.g. after, limit)
      # @return [Hash] a list object containing input item objects
      ##
      def list_input_items(response_id:, parameters: {})
        rest_index(
          resource: [RESOURCE, response_id, "input_items"],
          parameters: parameters
        )
      end

      private

      def create_streaming(parameters, &)
        parameters[:stream] = true
        rest_create_w_json_params_streamed(resource: RESOURCE,
                                           parameters: parameters, &)
      end
    end
  end
end
