RSpec.describe Asimov do
  it "has a version number" do
    expect(Asimov::VERSION).not_to be_nil
  end

  describe "#configure" do
    let(:access_token) { "abc123" }
    let(:organization_id) { "def456" }

    before do
      described_class.configure do |config|
        config.access_token = access_token
        config.organization_id = organization_id
      end
    end

    it "returns the config" do
      expect(described_class.configuration.access_token).to eq(access_token)
      expect(described_class.configuration.organization_id).to eq(organization_id)
    end
  end
end
