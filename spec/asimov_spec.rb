require_relative "spec_helper"

RSpec.describe Asimov do
  it "has a version number" do
    expect(Asimov::VERSION).not_to be_nil
  end

  describe "#configure" do
    context "when using default values" do
      it "has the expected default values" do
        expect(described_class.configuration.api_type).to eq("open_ai")
        expect(described_class.configuration.api_version).to be_nil
        expect(described_class.configuration.api_key).to be_nil
        expect(described_class.configuration.organization_id).to be_nil
        expect(described_class.configuration.request_options).to eq({})
        expect(described_class.configuration.openai_api_base).to eq("https://api.openai.com/v1")
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
          config.openai_api_base = openai_api_base
        end
      end

      context "when the base URI is normalized" do
        let(:openai_api_base) { "https://api.example.org/api/v2" }

        it "returns the normalized value" do
          expect(described_class.configuration.openai_api_base).to eq(openai_api_base)
        end
      end

      context "when the base URI is not normalized" do
        let(:openai_api_base) { "api.example.ai" }

        it "returns the normalized value with http:// prepended" do
          expect(described_class.configuration.openai_api_base).to eq("http://#{openai_api_base}")
        end
      end
    end

    describe "#api_type" do
      before do
        described_class.configure do |config|
          config.api_type = api_type
        end
      end

      context "when the api_type is nil" do
        let(:api_type) { nil }

        it "sets the API type to 'open_ai'" do
          expect(described_class.configuration.api_type).to eq("open_ai")
          expect(described_class.configuration.api_version).to be_nil
        end
      end

      context "when the api_type is 'open_ai'" do
        let(:api_type) { Utils.randomize_case("open_ai") }

        it "sets the API type to 'open_ai'" do
          expect(described_class.configuration.api_type).to eq("open_ai")
          expect(described_class.configuration.api_version).to be_nil
        end
      end

      context "when the api_type is 'openai'" do
        let(:api_type) { Utils.randomize_case("openai") }

        it "sets the API type to 'open_ai'" do
          expect(described_class.configuration.api_type).to eq("open_ai")
          expect(described_class.configuration.api_version).to be_nil
        end
      end

      context "when the api_type is 'azure'" do
        let(:api_type) { Utils.randomize_case("azure") }

        context "when no explicit version is set" do
          it "sets the API type to 'azure' and sets API version to '2022-12-01'" do
            expect(described_class.configuration.api_type).to eq("azure")
            expect(described_class.configuration.api_version).to eq("2022-12-01")
          end
        end

        context "when an explicit version is set" do
          let(:version) { SecureRandom.hex(4) }

          before do
            described_class.configure do |config|
              config.api_type = api_type
              config.api_version = version
            end
          end

          it "sets the API type to 'azure' and sets API version to explicitly set version" do
            expect(described_class.configuration.api_type).to eq("azure")
            expect(described_class.configuration.api_version).to eq(version)
          end
        end
      end

      context "when the api_type is 'azure_ad'" do
        let(:api_type) { Utils.randomize_case("azure_ad") }

        context "when no explicit version is set" do
          it "sets the API type to 'azure_ad' and sets API version to '2022-12-01'" do
            expect(described_class.configuration.api_type).to eq("azure_ad")
            expect(described_class.configuration.api_version).to eq("2022-12-01")
          end
        end

        context "when an explicit version is set" do
          let(:version) { SecureRandom.hex(4) }

          before do
            described_class.configure do |config|
              config.api_type = api_type
              config.api_version = version
            end
          end

          it "sets the API type to 'azure' and sets API version to explicitly set version" do
            expect(described_class.configuration.api_type).to eq("azure_ad")
            expect(described_class.configuration.api_version).to eq(version)
          end
        end
      end

      context "when the api_type is 'azuread'" do
        let(:api_type) { Utils.randomize_case("azuread") }

        context "when no explicit version is set" do
          it "sets the API type to 'azure_ad' and sets API version to '2022-12-01'" do
            expect(described_class.configuration.api_type).to eq("azure_ad")
            expect(described_class.configuration.api_version).to eq("2022-12-01")
          end
        end

        context "when an explicit version is set" do
          let(:version) { SecureRandom.hex(4) }

          before do
            described_class.configure do |config|
              config.api_type = api_type
              config.api_version = version
            end
          end

          it "sets the API type to 'azure' and sets API version to explicitly set version" do
            expect(described_class.configuration.api_type).to eq("azure_ad")
            expect(described_class.configuration.api_version).to eq(version)
          end
        end
      end
    end
  end
end
