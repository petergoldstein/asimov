module Asimov
  module ApiV1
    class Organization < Base
      ##
      # Mixin providing project management operations for the Organization API.
      # Includes project CRUD, project users, service accounts, API keys, and rate limits.
      ##
      module Projects # rubocop:disable Metrics/ModuleLength
        ##
        # Creates a project.
        #
        # @param [String] name the name of the project
        # @param [Hash] parameters additional parameters
        # @return [Hash] the created project object
        # @raise [Asimov::MissingRequiredParameterError] if name is missing
        ##
        def create_project(name:, parameters: {})
          raise MissingRequiredParameterError.new(:name) unless name

          rest_create_w_json_params(
            resource: PROJECTS_RESOURCE,
            parameters: parameters.merge(name: name)
          )
        end

        ##
        # Lists all projects in the organization.
        #
        # @param [Hash] parameters optional query parameters (e.g. after, limit, include_archived)
        # @return [Hash] a list object containing project objects
        ##
        def list_projects(parameters: {})
          rest_index(resource: PROJECTS_RESOURCE, parameters: parameters)
        end

        ##
        # Retrieves a project by ID.
        #
        # @param [String] project_id the ID of the project
        # @return [Hash] the project object
        ##
        def retrieve_project(project_id:)
          rest_get(resource: resource_path(PROJECTS_RESOURCE), id: project_id)
        end

        ##
        # Updates a project.
        #
        # @param [String] project_id the ID of the project to update
        # @param [Hash] parameters the parameters to update (e.g. name)
        # @return [Hash] the updated project object
        ##
        def update_project(project_id:, parameters: {})
          rest_create_w_json_params(
            resource: PROJECTS_RESOURCE + [project_id],
            parameters: parameters
          )
        end

        ##
        # Archives a project.
        #
        # @param [String] project_id the ID of the project to archive
        # @return [Hash] the archived project object
        ##
        def archive_project(project_id:)
          rest_create_w_json_params(
            resource: PROJECTS_RESOURCE + [project_id, "archive"],
            parameters: nil
          )
        end

        # -- Project Users --

        ##
        # Adds a user to a project.
        #
        # @param [String] project_id the ID of the project
        # @param [String] user_id the ID of the user to add
        # @param [String] role the role to assign to the user
        # @param [Hash] parameters additional parameters
        # @return [Hash] the created project user object
        # @raise [Asimov::MissingRequiredParameterError] if user_id or role is missing
        ##
        def create_project_user(project_id:, user_id:, role:, parameters: {})
          raise MissingRequiredParameterError.new(:user_id) unless user_id
          raise MissingRequiredParameterError.new(:role) unless role

          rest_create_w_json_params(
            resource: PROJECTS_RESOURCE + [project_id, "users"],
            parameters: parameters.merge(user_id: user_id, role: role)
          )
        end

        ##
        # Lists users in a project.
        #
        # @param [String] project_id the ID of the project
        # @param [Hash] parameters optional query parameters (e.g. after, limit)
        # @return [Hash] a list object containing project user objects
        ##
        def list_project_users(project_id:, parameters: {})
          rest_index(
            resource: PROJECTS_RESOURCE + [project_id, "users"],
            parameters: parameters
          )
        end

        ##
        # Retrieves a user in a project.
        #
        # @param [String] project_id the ID of the project
        # @param [String] user_id the ID of the user
        # @return [Hash] the project user object
        ##
        def retrieve_project_user(project_id:, user_id:)
          rest_get(
            resource: resource_path(PROJECTS_RESOURCE, project_id, "users"),
            id: user_id
          )
        end

        ##
        # Updates a user's role in a project.
        #
        # @param [String] project_id the ID of the project
        # @param [String] user_id the ID of the user to update
        # @param [String] role the new role for the user
        # @param [Hash] parameters additional parameters
        # @return [Hash] the updated project user object
        # @raise [Asimov::MissingRequiredParameterError] if role is missing
        ##
        def update_project_user(project_id:, user_id:, role:, parameters: {})
          raise MissingRequiredParameterError.new(:role) unless role

          rest_create_w_json_params(
            resource: PROJECTS_RESOURCE + [project_id, "users", user_id],
            parameters: parameters.merge(role: role)
          )
        end

        ##
        # Deletes a user from a project.
        #
        # @param [String] project_id the ID of the project
        # @param [String] user_id the ID of the user to delete
        # @return [Hash] deletion confirmation
        ##
        def delete_project_user(project_id:, user_id:)
          rest_delete(
            resource: resource_path(PROJECTS_RESOURCE, project_id, "users"),
            id: user_id
          )
        end

        # -- Service Accounts --

        ##
        # Creates a service account in a project.
        #
        # @param [String] project_id the ID of the project
        # @param [String] name the name of the service account
        # @param [Hash] parameters additional parameters
        # @return [Hash] the created service account object
        # @raise [Asimov::MissingRequiredParameterError] if name is missing
        ##
        def create_project_service_account(project_id:, name:, parameters: {})
          raise MissingRequiredParameterError.new(:name) unless name

          rest_create_w_json_params(
            resource: PROJECTS_RESOURCE + [project_id, "service_accounts"],
            parameters: parameters.merge(name: name)
          )
        end

        ##
        # Lists service accounts in a project.
        #
        # @param [String] project_id the ID of the project
        # @param [Hash] parameters optional query parameters (e.g. after, limit)
        # @return [Hash] a list object containing service account objects
        ##
        def list_project_service_accounts(project_id:, parameters: {})
          rest_index(
            resource: PROJECTS_RESOURCE + [project_id, "service_accounts"],
            parameters: parameters
          )
        end

        ##
        # Retrieves a service account in a project.
        #
        # @param [String] project_id the ID of the project
        # @param [String] service_account_id the ID of the service account
        # @return [Hash] the service account object
        ##
        def retrieve_project_service_account(project_id:, service_account_id:)
          rest_get(
            resource: resource_path(PROJECTS_RESOURCE, project_id, "service_accounts"),
            id: service_account_id
          )
        end

        ##
        # Deletes a service account from a project.
        #
        # @param [String] project_id the ID of the project
        # @param [String] service_account_id the ID of the service account to delete
        # @return [Hash] deletion confirmation
        ##
        def delete_project_service_account(project_id:, service_account_id:)
          rest_delete(
            resource: resource_path(PROJECTS_RESOURCE, project_id, "service_accounts"),
            id: service_account_id
          )
        end

        # -- Project API Keys --

        ##
        # Lists API keys in a project.
        #
        # @param [String] project_id the ID of the project
        # @param [Hash] parameters optional query parameters (e.g. after, limit)
        # @return [Hash] a list object containing API key objects
        ##
        def list_project_api_keys(project_id:, parameters: {})
          rest_index(
            resource: PROJECTS_RESOURCE + [project_id, "api_keys"],
            parameters: parameters
          )
        end

        ##
        # Retrieves an API key in a project.
        #
        # @param [String] project_id the ID of the project
        # @param [String] key_id the ID of the API key
        # @return [Hash] the API key object
        ##
        def retrieve_project_api_key(project_id:, key_id:)
          rest_get(
            resource: resource_path(PROJECTS_RESOURCE, project_id, "api_keys"),
            id: key_id
          )
        end

        ##
        # Deletes an API key from a project.
        #
        # @param [String] project_id the ID of the project
        # @param [String] key_id the ID of the API key to delete
        # @return [Hash] deletion confirmation
        ##
        def delete_project_api_key(project_id:, key_id:)
          rest_delete(
            resource: resource_path(PROJECTS_RESOURCE, project_id, "api_keys"),
            id: key_id
          )
        end

        # -- Rate Limits --

        ##
        # Lists rate limits for a project.
        #
        # @param [String] project_id the ID of the project
        # @param [Hash] parameters optional query parameters (e.g. after, limit)
        # @return [Hash] a list object containing rate limit objects
        ##
        def list_project_rate_limits(project_id:, parameters: {})
          rest_index(
            resource: PROJECTS_RESOURCE + [project_id, "rate_limits"],
            parameters: parameters
          )
        end

        ##
        # Updates a rate limit for a project.
        #
        # @param [String] project_id the ID of the project
        # @param [String] rate_limit_id the ID of the rate limit to update
        # @param [Hash] parameters the parameters to update
        # @return [Hash] the updated rate limit object
        ##
        def update_project_rate_limit(project_id:, rate_limit_id:, parameters: {})
          rest_create_w_json_params(
            resource: PROJECTS_RESOURCE + [project_id, "rate_limits", rate_limit_id],
            parameters: parameters
          )
        end
      end
    end
  end
end
