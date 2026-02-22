require_relative "../utils/file_manager"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/skills" URI subspace.
    ##
    class Skills < Base
      RESOURCE = "skills".freeze
      private_constant :RESOURCE

      ##
      # Creates a skill by uploading a zip file containing a SKILL.md manifest.
      #
      # @param [String] file file name or a File-like object to be uploaded
      # @param [Hash] parameters additional parameters
      # @return [Hash] the created skill object
      # @raise [Asimov::MissingRequiredParameterError] if file is missing
      ##
      def create(file:, parameters: {})
        raise MissingRequiredParameterError.new(:file) unless file

        rest_create_w_multipart_params(
          resource: RESOURCE,
          parameters: parameters.merge(files: Utils::FileManager.open(file))
        )
      end

      ##
      # Lists skills, optionally filtered by parameters.
      #
      # @param [Hash] parameters optional query parameters (e.g. after, limit, order)
      # @return [Hash] a list object containing skill objects
      ##
      def list(parameters: {})
        rest_index(resource: RESOURCE, parameters: parameters)
      end

      ##
      # Retrieves a skill by ID.
      #
      # @param [String] skill_id the ID of the skill
      # @return [Hash] the skill object
      ##
      def retrieve(skill_id:)
        raise MissingRequiredParameterError.new(:skill_id) unless skill_id

        rest_get(resource: RESOURCE, id: skill_id)
      end

      ##
      # Updates a skill.
      #
      # @param [String] skill_id the ID of the skill to update
      # @param [Hash] parameters the parameters to update (e.g. default_version)
      # @return [Hash] the updated skill object
      ##
      def update(skill_id:, parameters: {})
        raise MissingRequiredParameterError.new(:skill_id) unless skill_id

        rest_create_w_json_params(
          resource: [RESOURCE, skill_id],
          parameters: parameters
        )
      end

      ##
      # Deletes a skill by ID. Cascading — deletes all versions.
      #
      # @param [String] skill_id the ID of the skill to delete
      # @return [Hash] deletion confirmation
      ##
      def delete(skill_id:)
        raise MissingRequiredParameterError.new(:skill_id) unless skill_id

        rest_delete(resource: RESOURCE, id: skill_id)
      end

      ##
      # Downloads default version content as a streamed binary.
      #
      # @param [String] skill_id the ID of the skill
      # @param [Writer] writer the Writer that will process the chunked content
      ##
      def content(skill_id:, writer:)
        raise MissingRequiredParameterError.new(:skill_id) unless skill_id

        rest_get_streamed_download(
          resource: [RESOURCE, skill_id, "content"],
          writer: writer
        )
      end

      ##
      # Creates a new version of a skill by uploading a zip file.
      #
      # @param [String] skill_id the ID of the skill
      # @param [String] file file name or a File-like object to be uploaded
      # @param [Hash] parameters additional parameters
      # @return [Hash] the created version object
      # @raise [Asimov::MissingRequiredParameterError] if file is missing
      ##
      def create_version(skill_id:, file:, parameters: {})
        raise MissingRequiredParameterError.new(:skill_id) unless skill_id
        raise MissingRequiredParameterError.new(:file) unless file

        rest_create_w_multipart_params(
          resource: [RESOURCE, skill_id, "versions"],
          parameters: parameters.merge(files: Utils::FileManager.open(file))
        )
      end

      ##
      # Lists versions of a skill.
      #
      # @param [String] skill_id the ID of the skill
      # @param [Hash] parameters optional query parameters (e.g. after, limit, order)
      # @return [Hash] a list object containing version objects
      ##
      def list_versions(skill_id:, parameters: {})
        raise MissingRequiredParameterError.new(:skill_id) unless skill_id

        rest_index(
          resource: [RESOURCE, skill_id, "versions"],
          parameters: parameters
        )
      end

      ##
      # Retrieves a version of a skill.
      #
      # @param [String] skill_id the ID of the skill
      # @param [String, Integer] version the version number or "latest"
      # @return [Hash] the version object
      ##
      def retrieve_version(skill_id:, version:)
        raise MissingRequiredParameterError.new(:skill_id) unless skill_id
        raise MissingRequiredParameterError.new(:version) unless version

        rest_get(
          resource: resource_path(RESOURCE, skill_id, "versions"),
          id: version.to_s
        )
      end

      ##
      # Deletes a version of a skill.
      #
      # @param [String] skill_id the ID of the skill
      # @param [String, Integer] version the version number
      # @return [Hash] deletion confirmation
      ##
      def delete_version(skill_id:, version:)
        raise MissingRequiredParameterError.new(:skill_id) unless skill_id
        raise MissingRequiredParameterError.new(:version) unless version

        rest_delete(
          resource: resource_path(RESOURCE, skill_id, "versions"),
          id: version.to_s
        )
      end

      ##
      # Downloads version content as a streamed binary.
      #
      # @param [String] skill_id the ID of the skill
      # @param [String, Integer] version the version number or "latest"
      # @param [Writer] writer the Writer that will process the chunked content
      ##
      def version_content(skill_id:, version:, writer:)
        raise MissingRequiredParameterError.new(:skill_id) unless skill_id
        raise MissingRequiredParameterError.new(:version) unless version

        rest_get_streamed_download(
          resource: [RESOURCE, skill_id, "versions", version, "content"],
          writer: writer
        )
      end
    end
  end
end
