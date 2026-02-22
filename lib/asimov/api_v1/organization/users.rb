module Asimov
  module ApiV1
    class Organization < Base
      ##
      # Mixin providing user management operations for the Organization API.
      ##
      module Users
        ##
        # Lists all users in the organization.
        #
        # @param [Hash] parameters optional query parameters (e.g. after, limit)
        # @return [Hash] a list object containing user objects
        ##
        def list_users(parameters: {})
          rest_index(resource: USERS_RESOURCE, parameters: parameters)
        end

        ##
        # Retrieves a user by ID.
        #
        # @param [String] user_id the ID of the user
        # @return [Hash] the user object
        ##
        def retrieve_user(user_id:)
          rest_get(resource: resource_path(USERS_RESOURCE), id: user_id)
        end

        ##
        # Updates a user's role in the organization.
        #
        # @param [String] user_id the ID of the user to update
        # @param [String] role the new role for the user
        # @param [Hash] parameters additional parameters
        # @return [Hash] the updated user object
        # @raise [Asimov::MissingRequiredParameterError] if role is missing
        ##
        def update_user(user_id:, role:, parameters: {})
          raise MissingRequiredParameterError.new(:role) unless role

          rest_create_w_json_params(
            resource: USERS_RESOURCE + [user_id],
            parameters: parameters.merge(role: role)
          )
        end

        ##
        # Deletes a user from the organization.
        #
        # @param [String] user_id the ID of the user to delete
        # @return [Hash] deletion confirmation
        ##
        def delete_user(user_id:)
          rest_delete(resource: resource_path(USERS_RESOURCE), id: user_id)
        end
      end
    end
  end
end
