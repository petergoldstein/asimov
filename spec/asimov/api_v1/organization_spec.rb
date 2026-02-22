require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Organization do
  subject(:organization) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "organization" }

  it_behaves_like "sends requests to the v1 API"

  # -- Audit Logs --

  describe "#list_audit_logs" do
    it "calls rest_index with the expected arguments" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "audit_logs"], parameters: {})
        .and_return(ret_val)
      expect(organization.list_audit_logs).to eq(ret_val)
    end

    it "passes query parameters" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "audit_logs"], parameters: parameters)
        .and_return(ret_val)
      expect(organization.list_audit_logs(parameters: parameters)).to eq(ret_val)
    end
  end

  # -- Admin API Keys --

  describe "#create_admin_api_key" do
    let(:name) { "my-admin-key" }

    context "when name is present" do
      it "calls rest_create_w_json_params with the expected arguments" do
        merged = parameters.merge(name: name)
        allow(organization).to receive(:rest_create_w_json_params)
          .with(resource: [resource, "admin_api_keys"], parameters: merged)
          .and_return(ret_val)
        expect(organization.create_admin_api_key(name: name, parameters: parameters)).to eq(ret_val)
      end
    end

    context "when name is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.create_admin_api_key(name: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#list_admin_api_keys" do
    it "calls rest_index with the expected arguments" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "admin_api_keys"], parameters: {})
        .and_return(ret_val)
      expect(organization.list_admin_api_keys).to eq(ret_val)
    end

    it "passes query parameters" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "admin_api_keys"], parameters: parameters)
        .and_return(ret_val)
      expect(organization.list_admin_api_keys(parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#retrieve_admin_api_key" do
    let(:key_id) { "key_#{SecureRandom.hex(4)}" }

    context "when key_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.retrieve_admin_api_key(key_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(organization).to receive(:rest_get)
        .with(resource: "#{resource}/admin_api_keys", id: key_id)
        .and_return(ret_val)
      expect(organization.retrieve_admin_api_key(key_id: key_id)).to eq(ret_val)
    end
  end

  describe "#delete_admin_api_key" do
    let(:key_id) { "key_#{SecureRandom.hex(4)}" }

    context "when key_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.delete_admin_api_key(key_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(organization).to receive(:rest_delete)
        .with(resource: "#{resource}/admin_api_keys", id: key_id)
        .and_return(ret_val)
      expect(organization.delete_admin_api_key(key_id: key_id)).to eq(ret_val)
    end
  end

  # -- Users --

  describe "#list_users" do
    it "calls rest_index with the expected arguments" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "users"], parameters: {})
        .and_return(ret_val)
      expect(organization.list_users).to eq(ret_val)
    end

    it "passes query parameters" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "users"], parameters: parameters)
        .and_return(ret_val)
      expect(organization.list_users(parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#retrieve_user" do
    let(:user_id) { "user_#{SecureRandom.hex(4)}" }

    context "when user_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.retrieve_user(user_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(organization).to receive(:rest_get)
        .with(resource: "#{resource}/users", id: user_id)
        .and_return(ret_val)
      expect(organization.retrieve_user(user_id: user_id)).to eq(ret_val)
    end
  end

  describe "#update_user" do
    let(:user_id) { "user_#{SecureRandom.hex(4)}" }
    let(:role) { "reader" }

    context "when user_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.update_user(user_id: nil, role: role)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when role is present" do
      it "calls rest_create_w_json_params with the expected arguments" do
        merged = parameters.merge(role: role)
        allow(organization).to receive(:rest_create_w_json_params)
          .with(resource: [resource, "users", user_id], parameters: merged)
          .and_return(ret_val)
        expect(organization.update_user(user_id: user_id, role: role,
                                        parameters: parameters)).to eq(ret_val)
      end
    end

    context "when role is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.update_user(user_id: user_id, role: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#delete_user" do
    let(:user_id) { "user_#{SecureRandom.hex(4)}" }

    context "when user_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.delete_user(user_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(organization).to receive(:rest_delete)
        .with(resource: "#{resource}/users", id: user_id)
        .and_return(ret_val)
      expect(organization.delete_user(user_id: user_id)).to eq(ret_val)
    end
  end

  # -- Invites --

  describe "#create_invite" do
    let(:email) { "user@example.com" }
    let(:role) { "reader" }

    context "when email and role are present" do
      it "calls rest_create_w_json_params with the expected arguments" do
        merged = parameters.merge(email: email, role: role)
        allow(organization).to receive(:rest_create_w_json_params)
          .with(resource: [resource, "invites"], parameters: merged)
          .and_return(ret_val)
        expect(organization.create_invite(email: email, role: role,
                                          parameters: parameters)).to eq(ret_val)
      end
    end

    context "when email is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.create_invite(email: nil, role: role)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when role is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.create_invite(email: email, role: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#list_invites" do
    it "calls rest_index with the expected arguments" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "invites"], parameters: {})
        .and_return(ret_val)
      expect(organization.list_invites).to eq(ret_val)
    end

    it "passes query parameters" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "invites"], parameters: parameters)
        .and_return(ret_val)
      expect(organization.list_invites(parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#retrieve_invite" do
    let(:invite_id) { "inv_#{SecureRandom.hex(4)}" }

    context "when invite_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.retrieve_invite(invite_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(organization).to receive(:rest_get)
        .with(resource: "#{resource}/invites", id: invite_id)
        .and_return(ret_val)
      expect(organization.retrieve_invite(invite_id: invite_id)).to eq(ret_val)
    end
  end

  describe "#delete_invite" do
    let(:invite_id) { "inv_#{SecureRandom.hex(4)}" }

    context "when invite_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.delete_invite(invite_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(organization).to receive(:rest_delete)
        .with(resource: "#{resource}/invites", id: invite_id)
        .and_return(ret_val)
      expect(organization.delete_invite(invite_id: invite_id)).to eq(ret_val)
    end
  end

  # -- Projects --

  describe "#create_project" do
    let(:name) { "my-project" }

    context "when name is present" do
      it "calls rest_create_w_json_params with the expected arguments" do
        merged = parameters.merge(name: name)
        allow(organization).to receive(:rest_create_w_json_params)
          .with(resource: [resource, "projects"], parameters: merged)
          .and_return(ret_val)
        expect(organization.create_project(name: name, parameters: parameters)).to eq(ret_val)
      end
    end

    context "when name is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.create_project(name: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#list_projects" do
    it "calls rest_index with the expected arguments" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "projects"], parameters: {})
        .and_return(ret_val)
      expect(organization.list_projects).to eq(ret_val)
    end

    it "passes query parameters" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "projects"], parameters: parameters)
        .and_return(ret_val)
      expect(organization.list_projects(parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#retrieve_project" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.retrieve_project(project_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(organization).to receive(:rest_get)
        .with(resource: "#{resource}/projects", id: project_id)
        .and_return(ret_val)
      expect(organization.retrieve_project(project_id: project_id)).to eq(ret_val)
    end
  end

  describe "#update_project" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.update_project(project_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(organization).to receive(:rest_create_w_json_params)
        .with(resource: [resource, "projects", project_id], parameters: parameters)
        .and_return(ret_val)
      expect(organization.update_project(project_id: project_id,
                                         parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#archive_project" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.archive_project(project_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with nil parameters" do
      allow(organization).to receive(:rest_create_w_json_params)
        .with(resource: [resource, "projects", project_id, "archive"], parameters: nil)
        .and_return(ret_val)
      expect(organization.archive_project(project_id: project_id)).to eq(ret_val)
    end
  end

  # -- Project Users --

  describe "#create_project_user" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }
    let(:user_id) { "user_#{SecureRandom.hex(4)}" }
    let(:role) { "member" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.create_project_user(project_id: nil, user_id: user_id, role: role)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when user_id and role are present" do
      it "calls rest_create_w_json_params with the expected arguments" do
        merged = parameters.merge(user_id: user_id, role: role)
        allow(organization).to receive(:rest_create_w_json_params)
          .with(resource: [resource, "projects", project_id, "users"], parameters: merged)
          .and_return(ret_val)
        expect(organization.create_project_user(project_id: project_id, user_id: user_id,
                                                role: role,
                                                parameters: parameters)).to eq(ret_val)
      end
    end

    context "when user_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.create_project_user(project_id: project_id, user_id: nil, role: role)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when role is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.create_project_user(project_id: project_id, user_id: user_id, role: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#list_project_users" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.list_project_users(project_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "projects", project_id, "users"], parameters: {})
        .and_return(ret_val)
      expect(organization.list_project_users(project_id: project_id)).to eq(ret_val)
    end

    it "passes query parameters" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "projects", project_id, "users"], parameters: parameters)
        .and_return(ret_val)
      expect(organization.list_project_users(project_id: project_id,
                                             parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#retrieve_project_user" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }
    let(:user_id) { "user_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.retrieve_project_user(project_id: nil, user_id: user_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when user_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.retrieve_project_user(project_id: project_id, user_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(organization).to receive(:rest_get)
        .with(resource: "#{resource}/projects/#{project_id}/users", id: user_id)
        .and_return(ret_val)
      expect(organization.retrieve_project_user(project_id: project_id,
                                                user_id: user_id)).to eq(ret_val)
    end
  end

  describe "#update_project_user" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }
    let(:user_id) { "user_#{SecureRandom.hex(4)}" }
    let(:role) { "admin" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.update_project_user(project_id: nil, user_id: user_id, role: role)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when user_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.update_project_user(project_id: project_id, user_id: nil, role: role)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when role is present" do
      it "calls rest_create_w_json_params with the expected arguments" do
        merged = parameters.merge(role: role)
        allow(organization).to receive(:rest_create_w_json_params)
          .with(resource: [resource, "projects", project_id, "users", user_id],
                parameters: merged)
          .and_return(ret_val)
        expect(organization.update_project_user(project_id: project_id, user_id: user_id,
                                                role: role,
                                                parameters: parameters)).to eq(ret_val)
      end
    end

    context "when role is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.update_project_user(project_id: project_id, user_id: user_id, role: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#delete_project_user" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }
    let(:user_id) { "user_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.delete_project_user(project_id: nil, user_id: user_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when user_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.delete_project_user(project_id: project_id, user_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(organization).to receive(:rest_delete)
        .with(resource: "#{resource}/projects/#{project_id}/users", id: user_id)
        .and_return(ret_val)
      expect(organization.delete_project_user(project_id: project_id,
                                              user_id: user_id)).to eq(ret_val)
    end
  end

  # -- Service Accounts --

  describe "#create_project_service_account" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }
    let(:name) { "my-service-account" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.create_project_service_account(project_id: nil, name: name)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when name is present" do
      it "calls rest_create_w_json_params with the expected arguments" do
        merged = parameters.merge(name: name)
        allow(organization).to receive(:rest_create_w_json_params)
          .with(resource: [resource, "projects", project_id, "service_accounts"],
                parameters: merged)
          .and_return(ret_val)
        expect(organization.create_project_service_account(project_id: project_id, name: name,
                                                           parameters: parameters)).to eq(ret_val)
      end
    end

    context "when name is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.create_project_service_account(project_id: project_id, name: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#list_project_service_accounts" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.list_project_service_accounts(project_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "projects", project_id, "service_accounts"], parameters: {})
        .and_return(ret_val)
      expect(organization.list_project_service_accounts(project_id: project_id)).to eq(ret_val)
    end

    it "passes query parameters" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "projects", project_id, "service_accounts"],
              parameters: parameters)
        .and_return(ret_val)
      expect(organization.list_project_service_accounts(project_id: project_id,
                                                        parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#retrieve_project_service_account" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }
    let(:service_account_id) { "sa_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.retrieve_project_service_account(project_id: nil,
                                                        service_account_id: service_account_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when service_account_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.retrieve_project_service_account(project_id: project_id,
                                                        service_account_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(organization).to receive(:rest_get)
        .with(resource: "#{resource}/projects/#{project_id}/service_accounts",
              id: service_account_id)
        .and_return(ret_val)
      expect(organization.retrieve_project_service_account(
               project_id: project_id,
               service_account_id: service_account_id
             )).to eq(ret_val)
    end
  end

  describe "#delete_project_service_account" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }
    let(:service_account_id) { "sa_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.delete_project_service_account(project_id: nil,
                                                      service_account_id: service_account_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when service_account_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.delete_project_service_account(project_id: project_id,
                                                      service_account_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(organization).to receive(:rest_delete)
        .with(resource: "#{resource}/projects/#{project_id}/service_accounts",
              id: service_account_id)
        .and_return(ret_val)
      expect(organization.delete_project_service_account(
               project_id: project_id,
               service_account_id: service_account_id
             )).to eq(ret_val)
    end
  end

  # -- Project API Keys --

  describe "#list_project_api_keys" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.list_project_api_keys(project_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "projects", project_id, "api_keys"], parameters: {})
        .and_return(ret_val)
      expect(organization.list_project_api_keys(project_id: project_id)).to eq(ret_val)
    end

    it "passes query parameters" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "projects", project_id, "api_keys"], parameters: parameters)
        .and_return(ret_val)
      expect(organization.list_project_api_keys(project_id: project_id,
                                                parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#retrieve_project_api_key" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }
    let(:key_id) { "key_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.retrieve_project_api_key(project_id: nil, key_id: key_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when key_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.retrieve_project_api_key(project_id: project_id, key_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(organization).to receive(:rest_get)
        .with(resource: "#{resource}/projects/#{project_id}/api_keys", id: key_id)
        .and_return(ret_val)
      expect(organization.retrieve_project_api_key(project_id: project_id,
                                                   key_id: key_id)).to eq(ret_val)
    end
  end

  describe "#delete_project_api_key" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }
    let(:key_id) { "key_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.delete_project_api_key(project_id: nil, key_id: key_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when key_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.delete_project_api_key(project_id: project_id, key_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(organization).to receive(:rest_delete)
        .with(resource: "#{resource}/projects/#{project_id}/api_keys", id: key_id)
        .and_return(ret_val)
      expect(organization.delete_project_api_key(project_id: project_id,
                                                 key_id: key_id)).to eq(ret_val)
    end
  end

  # -- Rate Limits --

  describe "#list_project_rate_limits" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.list_project_rate_limits(project_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "projects", project_id, "rate_limits"], parameters: {})
        .and_return(ret_val)
      expect(organization.list_project_rate_limits(project_id: project_id)).to eq(ret_val)
    end

    it "passes query parameters" do
      allow(organization).to receive(:rest_index)
        .with(resource: [resource, "projects", project_id, "rate_limits"], parameters: parameters)
        .and_return(ret_val)
      expect(organization.list_project_rate_limits(project_id: project_id,
                                                   parameters: parameters)).to eq(ret_val)
    end
  end

  describe "#update_project_rate_limit" do
    let(:project_id) { "proj_#{SecureRandom.hex(4)}" }
    let(:rate_limit_id) { "rl_#{SecureRandom.hex(4)}" }

    context "when project_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.update_project_rate_limit(project_id: nil, rate_limit_id: rate_limit_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when rate_limit_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          organization.update_project_rate_limit(project_id: project_id, rate_limit_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(organization).to receive(:rest_create_w_json_params)
        .with(resource: [resource, "projects", project_id, "rate_limits", rate_limit_id],
              parameters: parameters)
        .and_return(ret_val)
      expect(organization.update_project_rate_limit(project_id: project_id,
                                                    rate_limit_id: rate_limit_id,
                                                    parameters: parameters)).to eq(ret_val)
    end
  end
end
