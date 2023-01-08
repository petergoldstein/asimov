require_relative "./spec_helper"

RSpec.describe Asimov do
  it "has a version number" do
    expect(Asimov::VERSION).not_to be_nil
  end

  describe "#configure" do
    let(:api_key) { "abc123" }
    let(:organization_id) { "def456" }

    before do
      described_class.configure do |config|
        config.api_key = api_key
        config.organization_id = organization_id
      end
    end

    it "returns the config" do
      expect(described_class.configuration.api_key).to eq(api_key)
      expect(described_class.configuration.organization_id).to eq(organization_id)
    end
  end
end
