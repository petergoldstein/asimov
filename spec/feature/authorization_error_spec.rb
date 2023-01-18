require_relative "../spec_helper"

RSpec.describe "Authorization", type: :feature do
  describe "Invalid API key", :vcr do
    let(:client) { Asimov::Client.new(api_key: "invalid_key") }

    it "returns the expected error" do
      VCR.use_cassette("authenticate_invalid_api_key") do
        expect do
          client.models.list
        end.to raise_error(Asimov::InvalidApiKeyError)
      end
    end
  end

  describe "Invalid organization id", :vcr do
    let(:client) { Asimov::Client.new(organization_id: "invalid_id") }

    it "returns the expected error" do
      VCR.use_cassette("authenticate_invalid_organization_id") do
        expect do
          client.models.list
        end.to raise_error(Asimov::InvalidOrganizationError)
      end
    end
  end
end
