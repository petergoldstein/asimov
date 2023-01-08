require_relative "../spec_helper"

RSpec.describe Asimov::HeadersFactory do
  describe ".initialize" do
    let(:per_client_api_key) { SecureRandom.hex(4) }
    let(:per_client_organization_id) { SecureRandom.hex(4) }

    context "when the global configuration includes an API key" do
      let(:global_api_key) { SecureRandom.hex(4) }
      let(:global_organization_id) { SecureRandom.hex(4) }

      context "when the global configuration does not include an organization_id" do
        before do
          Asimov.configure do |config|
            config.api_key = global_api_key
          end
        end

        it "uses the global api_key when passed nil" do
          hf = nil
          expect do
            hf = described_class.new(nil,
                                     described_class::NULL_ORGANIZATION_ID)
          end.not_to raise_error
          expect(hf.api_key).to eq(global_api_key)
          expect(hf.organization_id).to be_nil
        end

        it "allows override of the global API key" do
          hf = nil
          expect do
            hf = described_class.new(per_client_api_key,
                                     described_class::NULL_ORGANIZATION_ID)
          end.not_to raise_error
          expect(hf.api_key).to eq(per_client_api_key)
          expect(hf.organization_id).to be_nil
        end

        it "allows setting of an organization_id with the api_key" do
          hf = nil
          expect do
            hf = described_class.new(per_client_api_key,
                                     per_client_organization_id)
          end.not_to raise_error
          expect(hf.api_key).to eq(per_client_api_key)
          expect(hf.organization_id).to eq(per_client_organization_id)
        end
      end

      context "when the global configuration includes an organization_id" do
        before do
          Asimov.configure do |config|
            config.api_key = global_api_key
            config.organization_id = global_organization_id
          end
        end

        it "allows override of the global configuration with a nil organization id in tandem " \
           "with a per client API key" do
          hf = nil
          expect do
            hf = described_class.new(per_client_api_key, nil)
          end.not_to raise_error
          expect(hf.api_key).to eq(per_client_api_key)
          expect(hf.organization_id).to be_nil
        end

        it "allows override of the global configuration with a different organization id with " \
           "a per client API key" do
          hf = nil
          expect do
            hf = described_class.new(per_client_api_key,
                                     per_client_organization_id)
          end.not_to raise_error
          expect(hf.api_key).to eq(per_client_api_key)
          expect(hf.organization_id).to eq(per_client_organization_id)
        end
      end
    end

    context "when the global configuration does not include an API key" do
      it "raises an error when initialized with no arguments" do
        expect do
          described_class.new(nil,
                              described_class::NULL_ORGANIZATION_ID)
        end.to raise_error(Asimov::MissingApiKeyError)
      end

      it "initializes successfully when passed an api_key and a null object organization_id" do
        hf = nil
        expect do
          hf = described_class.new(per_client_api_key,
                                   described_class::NULL_ORGANIZATION_ID)
        end.not_to raise_error
        expect(hf.api_key).to eq(per_client_api_key)
        expect(hf.organization_id).to be_nil
      end

      it "initializes successfully when passed an api_key and a nil organization_id" do
        hf = nil
        expect do
          hf = described_class.new(per_client_api_key,
                                   nil)
        end.not_to raise_error
        expect(hf.api_key).to eq(per_client_api_key)
        expect(hf.organization_id).to be_nil
      end

      it "allows the client to set a per-client organization_id" do
        hf = nil
        expect do
          hf = described_class.new(per_client_api_key,
                                   per_client_organization_id)
        end.not_to raise_error
        expect(hf.api_key).to eq(per_client_api_key)
        expect(hf.organization_id).to eq(per_client_organization_id)
      end
    end
  end

  describe "#headers" do
    let(:api_key) { SecureRandom.hex(4) }

    context "when called with no arguments" do
      subject(:headers) do
        described_class.new(api_key, organization_id).headers
      end

      context "when the organization_id is nil" do
        let(:organization_id) { described_class::NULL_ORGANIZATION_ID }

        it "returns the expected headers" do
          expect(headers.size).to eq(2)
          expect(headers["Content-Type"]).to eq("application/json")
          expect(headers["Authorization"]).to eq("Bearer #{api_key}")
        end
      end

      context "when the organization_id is not nil" do
        let(:organization_id) { SecureRandom.hex(4) }

        it "returns the expected headers" do
          expect(headers.size).to eq(3)
          expect(headers["Content-Type"]).to eq("application/json")
          expect(headers["Authorization"]).to eq("Bearer #{api_key}")
          expect(headers["OpenAI-Organization"]).to eq(organization_id)
        end
      end
    end

    context "when called with an explicit content_type" do
      subject(:headers) do
        described_class.new(api_key,
                            organization_id).headers(content_type)
      end

      let(:content_type) { SecureRandom.hex(5) }

      context "when the organization_id is nil" do
        let(:organization_id) { described_class::NULL_ORGANIZATION_ID }

        it "returns the expected headers" do
          expect(headers.size).to eq(2)
          expect(headers["Content-Type"]).to eq(content_type)
          expect(headers["Authorization"]).to eq("Bearer #{api_key}")
        end
      end

      context "when the organization_id is not nil" do
        let(:organization_id) { SecureRandom.hex(4) }

        it "returns the expected headers" do
          expect(headers.size).to eq(3)
          expect(headers["Content-Type"]).to eq(content_type)
          expect(headers["Authorization"]).to eq("Bearer #{api_key}")
          expect(headers["OpenAI-Organization"]).to eq(organization_id)
        end
      end
    end
  end
end
