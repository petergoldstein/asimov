require_relative "organization/users"
require_relative "organization/invites"
require_relative "organization/projects"

module Asimov
  module ApiV1
    ##
    # Class interface for API methods in the "/organization" URI subspace.
    # Covers users, invites, projects (and their sub-resources), audit logs,
    # and admin API keys.
    ##
    class Organization < Base
      include Users
      include Invites
      include Projects

      RESOURCE = "organization".freeze
      USERS_RESOURCE = [RESOURCE, "users"].freeze
      INVITES_RESOURCE = [RESOURCE, "invites"].freeze
      PROJECTS_RESOURCE = [RESOURCE, "projects"].freeze
      AUDIT_LOGS_RESOURCE = [RESOURCE, "audit_logs"].freeze
      ADMIN_API_KEYS_RESOURCE = [RESOURCE, "admin_api_keys"].freeze
      private_constant :RESOURCE, :USERS_RESOURCE, :INVITES_RESOURCE,
                       :PROJECTS_RESOURCE, :AUDIT_LOGS_RESOURCE,
                       :ADMIN_API_KEYS_RESOURCE

      # -- Audit Logs --

      ##
      # Lists audit logs for the organization.
      #
      # @param [Hash] parameters optional query parameters (e.g. after, limit, effective_at)
      # @return [Hash] a list object containing audit log objects
      ##
      def list_audit_logs(parameters: {})
        rest_index(resource: AUDIT_LOGS_RESOURCE, parameters: parameters)
      end

      # -- Admin API Keys --

      ##
      # Creates an admin API key for the organization.
      #
      # @param [String] name the name of the admin API key
      # @param [Hash] parameters additional parameters
      # @return [Hash] the created admin API key object
      # @raise [Asimov::MissingRequiredParameterError] if name is missing
      ##
      def create_admin_api_key(name:, parameters: {})
        raise MissingRequiredParameterError.new(:name) unless name

        rest_create_w_json_params(
          resource: ADMIN_API_KEYS_RESOURCE,
          parameters: parameters.merge(name: name)
        )
      end

      ##
      # Lists admin API keys for the organization.
      #
      # @param [Hash] parameters optional query parameters (e.g. after, limit)
      # @return [Hash] a list object containing admin API key objects
      ##
      def list_admin_api_keys(parameters: {})
        rest_index(resource: ADMIN_API_KEYS_RESOURCE, parameters: parameters)
      end

      ##
      # Retrieves an admin API key by ID.
      #
      # @param [String] key_id the ID of the admin API key
      # @return [Hash] the admin API key object
      ##
      def retrieve_admin_api_key(key_id:)
        raise MissingRequiredParameterError.new(:key_id) unless key_id

        rest_get(resource: resource_path(ADMIN_API_KEYS_RESOURCE), id: key_id)
      end

      ##
      # Deletes an admin API key by ID.
      #
      # @param [String] key_id the ID of the admin API key to delete
      # @return [Hash] deletion confirmation
      ##
      def delete_admin_api_key(key_id:)
        raise MissingRequiredParameterError.new(:key_id) unless key_id

        rest_delete(resource: resource_path(ADMIN_API_KEYS_RESOURCE), id: key_id)
      end
    end
  end
end
