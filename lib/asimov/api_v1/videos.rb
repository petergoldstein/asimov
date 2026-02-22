module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/videos" URI subspace.
    ##
    class Videos < Base
      RESOURCE = "videos".freeze
      private_constant :RESOURCE

      ##
      # Creates a video generation job.
      #
      # @param [String] model the model to use for video generation
      # @param [String] prompt the prompt describing the video to generate
      # @param [Hash] parameters additional parameters passed to the API
      ##
      def create(model:, prompt:, parameters: {})
        raise MissingRequiredParameterError.new(:model) unless model
        raise MissingRequiredParameterError.new(:prompt) unless prompt

        rest_create_w_json_params(resource: RESOURCE,
                                  parameters: parameters.merge(model: model, prompt: prompt))
      end

      ##
      # Lists videos.
      #
      # @param [Hash] parameters optional query parameters (e.g. after, limit, order)
      ##
      def list(parameters: {})
        rest_index(resource: RESOURCE, parameters: parameters)
      end

      ##
      # Retrieves a video by ID.
      #
      # @param [String] video_id the ID of the video to retrieve
      ##
      def retrieve(video_id:)
        raise MissingRequiredParameterError.new(:video_id) unless video_id

        rest_get(resource: RESOURCE, id: video_id)
      end

      ##
      # Deletes a video by ID.
      #
      # @param [String] video_id the ID of the video to delete
      ##
      def delete(video_id:)
        raise MissingRequiredParameterError.new(:video_id) unless video_id

        rest_delete(resource: RESOURCE, id: video_id)
      end

      ##
      # Downloads video content as a streamed binary.
      #
      # @param [String] video_id the ID of the video
      # @param [Writer] writer the Writer that will process the chunked content
      ##
      def content(video_id:, writer:)
        raise MissingRequiredParameterError.new(:video_id) unless video_id

        rest_get_streamed_download(resource: [RESOURCE, video_id, "content"], writer: writer)
      end

      ##
      # Remixes an existing video with a new prompt.
      #
      # @param [String] video_id the ID of the video to remix
      # @param [String] prompt the prompt describing the remix
      # @param [Hash] parameters additional parameters passed to the API
      ##
      def remix(video_id:, prompt:, parameters: {})
        raise MissingRequiredParameterError.new(:video_id) unless video_id
        raise MissingRequiredParameterError.new(:prompt) unless prompt

        rest_create_w_json_params(resource: [RESOURCE, video_id, "remix"],
                                  parameters: parameters.merge(prompt: prompt))
      end
    end
  end
end
