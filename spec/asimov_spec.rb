require_relative "./spec_helper"

RSpec.describe Asimov do
  it "has a version number" do
    expect(Asimov::VERSION).not_to be_nil
  end

  describe "#configure" do
    context "when using default values" do
      it "has the expected default values" do
        expect(described_class.configuration.api_key).to be_nil
        expect(described_class.configuration.organization_id).to be_nil
        expect(described_class.configuration.request_options).to eq({})
        expect(described_class.configuration.base_uri).to eq("https://api.openai.com/v1")
      end
    end

    context "when configuring a custom API key and organization ID" do
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

    context "when configuring request options" do
      let(:request_options) { { read_timeout: 1234 } }

      before do
        described_class.configure do |config|
          config.request_options = request_options
        end
      end

      it "returns the configured request_options" do
        expect(described_class.configuration.request_options).to eq(request_options)
      end
    end

    context "when configuring a base URI" do
      before do
        described_class.configure do |config|
          config.base_uri = base_uri
        end
      end

      context "when the base URI is normalized" do
        let(:base_uri) { "https://api.example.org/api/v2" }

        it "returns the normalized value" do
          expect(described_class.configuration.base_uri).to eq(base_uri)
        end
      end

      context "when the base URI is not normalized" do
        let(:base_uri) { "api.example.ai" }

        it "returns the normalized value with http:// prepended" do
          expect(described_class.configuration.base_uri).to eq("http://#{base_uri}")
        end
      end
    end
  end
end
