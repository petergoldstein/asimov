module Asimov
  module ApiV1
    class Organization < Base
      ##
      # Mixin providing invite management operations for the Organization API.
      ##
      module Invites
        ##
        # Creates an invite for a user to join the organization.
        #
        # @param [String] email the email address of the invitee
        # @param [String] role the role to assign to the invitee
        # @param [Hash] parameters additional parameters
        # @return [Hash] the created invite object
        # @raise [Asimov::MissingRequiredParameterError] if email or role is missing
        ##
        def create_invite(email:, role:, parameters: {})
          raise MissingRequiredParameterError.new(:email) unless email
          raise MissingRequiredParameterError.new(:role) unless role

          rest_create_w_json_params(
            resource: INVITES_RESOURCE,
            parameters: parameters.merge(email: email, role: role)
          )
        end

        ##
        # Lists all invites in the organization.
        #
        # @param [Hash] parameters optional query parameters (e.g. after, limit)
        # @return [Hash] a list object containing invite objects
        ##
        def list_invites(parameters: {})
          rest_index(resource: INVITES_RESOURCE, parameters: parameters)
        end

        ##
        # Retrieves an invite by ID.
        #
        # @param [String] invite_id the ID of the invite
        # @return [Hash] the invite object
        ##
        def retrieve_invite(invite_id:)
          raise MissingRequiredParameterError.new(:invite_id) unless invite_id

          rest_get(resource: resource_path(INVITES_RESOURCE), id: invite_id)
        end

        ##
        # Deletes an invite from the organization.
        #
        # @param [String] invite_id the ID of the invite to delete
        # @return [Hash] deletion confirmation
        ##
        def delete_invite(invite_id:)
          raise MissingRequiredParameterError.new(:invite_id) unless invite_id

          rest_delete(resource: resource_path(INVITES_RESOURCE), id: invite_id)
        end
      end
    end
  end
end
