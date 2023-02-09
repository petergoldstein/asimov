require_relative "../spec_helper"

RSpec.describe Asimov::Client do
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

        it "can be initialized with no arguments and sets values from the global configuration" do
          client = nil
          expect do
            client = described_class.new
          end.not_to raise_error
          expect(client.api_key).to eq(global_api_key)
          expect(client.organization_id).to be_nil
        end

        it "allows override of the global API key" do
          client = nil
          expect do
            client = described_class.new(api_key: per_client_api_key)
          end.not_to raise_error
          expect(client.api_key).to eq(per_client_api_key)
          expect(client.organization_id).to be_nil
        end

        it "allows setting of an organization_id with the api_key" do
          client = nil
          expect do
            client = described_class.new(api_key: per_client_api_key,
                                         organization_id: per_client_organization_id)
          end.not_to raise_error
          expect(client.api_key).to eq(per_client_api_key)
          expect(client.organization_id).to eq(per_client_organization_id)
        end
      end

      context "when the global configuration includes an organization_id" do
        before do
          Asimov.configure do |config|
            config.api_key = global_api_key
            config.organization_id = global_organization_id
          end
        end

        it "can be initialized with no arguments and sets values from the global configuration" do
          client = nil
          expect do
            client = described_class.new
          end.not_to raise_error
          expect(client.api_key).to eq(global_api_key)
          expect(client.organization_id).to eq(global_organization_id)
        end

        it "allows override of the global configuration with a nil organization id" do
          client = nil
          expect do
            client = described_class.new(organization_id: nil)
          end.not_to raise_error
          expect(client.api_key).to eq(global_api_key)
          expect(client.organization_id).to be_nil
        end

        it "allows override of the global configuration with a different organization id" do
          client = nil
          expect do
            client = described_class.new(organization_id: per_client_organization_id)
          end.not_to raise_error
          expect(client.api_key).to eq(global_api_key)
          expect(client.organization_id).to eq(per_client_organization_id)
        end

        it "allows override of the global configuration with a nil organization id in tandem " \
           "with a per client API key" do
          client = nil
          expect do
            client = described_class.new(api_key: per_client_api_key,
                                         organization_id: nil)
          end.not_to raise_error
          expect(client.api_key).to eq(per_client_api_key)
          expect(client.organization_id).to be_nil
        end

        it "allows override of the global configuration with a different organization id with " \
           "a per client API key" do
          client = nil
          expect do
            client = described_class.new(api_key: per_client_api_key,
                                         organization_id: per_client_organization_id)
          end.not_to raise_error
          expect(client.api_key).to eq(per_client_api_key)
          expect(client.organization_id).to eq(per_client_organization_id)
        end
      end
    end

    context "when the global configuration does not include an API key" do
      it "raises an error when initialized with no arguments" do
        expect do
          described_class.new
        end.to raise_error(Asimov::MissingApiKeyError)
      end

      it "initializes successfully when passed an api_key" do
        client = nil
        expect do
          client = described_class.new(api_key: per_client_api_key)
        end.not_to raise_error
        expect(client.api_key).to eq(per_client_api_key)
        expect(client.organization_id).to be_nil
      end

      it "allows the client to set a per-client organization_id" do
        client = nil
        expect do
          client = described_class.new(api_key: per_client_api_key,
                                       organization_id: per_client_organization_id)
        end.not_to raise_error
        expect(client.api_key).to eq(per_client_api_key)
        expect(client.organization_id).to eq(per_client_organization_id)
      end
    end

    context "when the client is passed a set of request options" do
      context "when the configuration has no application-wide request options" do
        let(:api_key) { SecureRandom.hex(4) }
        let(:request_options) { { read_timeout: 1234, write_timeout: 1234 } }
        let(:client) { described_class.new(api_key: api_key, request_options: request_options) }

        context "when the request options are valid" do
          let(:frozen_options) { request_options }

          before do
            allow(Asimov::Utils::RequestOptionsValidator).to receive(:validate)
              .with(request_options)
              .and_return(request_options)
          end

          it "freezes and memoizes the request options" do
            expect(client.request_options).to eq(frozen_options)
            expect(Asimov::Utils::RequestOptionsValidator).to have_received(:validate)
              .with(request_options)
          end
        end

        context "when the request options are invalid" do
          let(:request_options) { { bad_option: 1234 } }

          before do
            allow(Asimov::Utils::RequestOptionsValidator).to receive(:validate)
              .with(request_options)
              .and_raise(Asimov::ConfigurationError)
          end

          it "raises a Configuration error" do
            expect do
              client
            end.to raise_error(Asimov::ConfigurationError)
          end
        end
      end

      context "when the configuration has application-wide request options" do
        let(:api_key) { SecureRandom.hex(4) }
        let(:application_request_options) { { open_timeout: 5678, read_timeout: 5678 } }
        let(:request_options) { { read_timeout: 1234, write_timeout: 1234 } }
        let(:client) { described_class.new(api_key: api_key, request_options: request_options) }

        before do
          Asimov.configure do |config|
            config.request_options = application_request_options
          end
        end

        context "when the request options are valid" do
          let(:frozen_options) { application_request_options.merge(request_options).freeze }

          before do
            allow(Asimov::Utils::RequestOptionsValidator).to receive(:validate)
              .with(request_options)
              .and_return(request_options)
          end

          it "merges and overrides application options and freezes and memoizes the result" do
            expect(client.request_options).to eq(frozen_options)
            expect(Asimov::Utils::RequestOptionsValidator).to have_received(:validate)
              .with(request_options)
            expect(client.request_options[:read_timeout]).to eq(1234)
            expect(client.request_options[:open_timeout]).to eq(5678)
          end
        end

        context "when the request options are invalid" do
          let(:request_options) { { bad_option: 1234 } }

          before do
            allow(Asimov::Utils::RequestOptionsValidator).to receive(:validate)
              .with(request_options)
              .and_raise(Asimov::ConfigurationError)
          end

          it "raises a Configuration error" do
            expect do
              client
            end.to raise_error(Asimov::ConfigurationError)
          end
        end
      end
    end

    context "when the global configuration includes a custom base URI" do
      let(:api_key) { SecureRandom.hex(4) }
      let(:client) { described_class.new(api_key: api_key) }

      before do
        Asimov.configure do |config|
          config.base_uri = base_uri
        end
      end

      context "when the configured base URI is nil" do
        let(:base_uri) { nil }

        it "raises an error" do
          expect { client }.to raise_error Asimov::MissingBaseUriError
        end

        context "when the client is passed an explicit normalized base_uri" do
          let(:base_uri) { "https://exampleapi.org/v2" }

          it "returns the override base URI" do
            expect(client.base_uri).to eq(base_uri)
          end
        end

        context "when the client is passed an not normalized base_uri" do
          let(:base_uri) { "exampleapi.org/v2" }
          let(:normalized_base_uri) { HTTParty.normalize_base_uri(base_uri) }

          it "returns the normalized override base URI" do
            expect(client.base_uri).to eq(normalized_base_uri)
          end
        end
      end

      context "when the configured base URI is a normalized URI" do
        let(:base_uri) { "https://moose.squirrel.net/v1/api" }

        it "sets the URI in the client" do
          expect(client.base_uri).to eq(base_uri)
        end

        context "when the client is passed an explicit normalized base_uri" do
          let(:base_uri) { "https://exampleapi.org/v2" }

          it "returns the override base URI" do
            expect(client.base_uri).to eq(base_uri)
          end
        end

        context "when the client is passed an not normalized base_uri" do
          let(:base_uri) { "exampleapi.org/v2" }
          let(:normalized_base_uri) { HTTParty.normalize_base_uri(base_uri) }

          it "returns the normalized override base URI" do
            expect(client.base_uri).to eq(normalized_base_uri)
          end
        end
      end

      context "when the configured base URI is not a normalized URI" do
        let(:base_uri) { "rocky.bullwinkle.net/v1/api" }

        it "normalizes the URI and sets in the client" do
          expect(client.base_uri).to eq("http://#{base_uri}")
        end

        context "when the client is passed an explicit normalized base_uri" do
          let(:base_uri) { "https://exampleapi.org/v2" }

          it "returns the override base URI" do
            expect(client.base_uri).to eq(base_uri)
          end
        end

        context "when the client is passed an not normalized base_uri" do
          let(:base_uri) { "exampleapi.org/v2" }
          let(:normalized_base_uri) { HTTParty.normalize_base_uri(base_uri) }

          it "returns the normalized override base URI" do
            expect(client.base_uri).to eq(normalized_base_uri)
          end
        end
      end
    end
  end

  describe "#completions" do
    let(:api_key) { SecureRandom.hex(4) }
    let(:client) { described_class.new(api_key: api_key) }
    let(:interface) { instance_double(Asimov::ApiV1::Completions) }

    it "loads an Asimov::ApiV1::Completions object initialized with the client" do
      allow(Asimov::ApiV1::Completions).to receive(:new).with(client: client)
                                                        .and_return(interface)
      expect(client.completions).to eq(interface)
      expect(Asimov::ApiV1::Completions).to have_received(:new).with(client: client)
    end
  end

  describe "#edits" do
    let(:api_key) { SecureRandom.hex(4) }
    let(:client) { described_class.new(api_key: api_key) }
    let(:interface) { instance_double(Asimov::ApiV1::Edits) }

    it "loads an Asimov::ApiV1::Edits object initialized with the client" do
      allow(Asimov::ApiV1::Edits).to receive(:new).with(client: client).and_return(interface)
      expect(client.edits).to eq(interface)
      expect(Asimov::ApiV1::Edits).to have_received(:new).with(client: client)
    end
  end

  describe "#embeddings" do
    let(:api_key) { SecureRandom.hex(4) }
    let(:client) { described_class.new(api_key: api_key) }
    let(:interface) { instance_double(Asimov::ApiV1::Embeddings) }

    it "loads an Asimov::ApiV1::Embeddings object initialized with the client" do
      allow(Asimov::ApiV1::Embeddings).to receive(:new).with(client: client)
                                                       .and_return(interface)
      expect(client.embeddings).to eq(interface)
      expect(Asimov::ApiV1::Embeddings).to have_received(:new).with(client: client)
    end
  end

  describe "#files" do
    let(:api_key) { SecureRandom.hex(4) }
    let(:client) { described_class.new(api_key: api_key) }
    let(:interface) { instance_double(Asimov::ApiV1::Files) }

    it "loads an Asimov::ApiV1::Files object initialized with the client" do
      allow(Asimov::ApiV1::Files).to receive(:new).with(client: client).and_return(interface)
      expect(client.files).to eq(interface)
      expect(Asimov::ApiV1::Files).to have_received(:new).with(client: client)
    end
  end

  describe "#finetunes" do
    let(:api_key) { SecureRandom.hex(4) }
    let(:client) { described_class.new(api_key: api_key) }
    let(:interface) { instance_double(Asimov::ApiV1::Finetunes) }

    it "loads an Asimov::ApiV1::Finetunes object initialized with the client" do
      allow(Asimov::ApiV1::Finetunes).to receive(:new).with(client: client)
                                                      .and_return(interface)
      expect(client.finetunes).to eq(interface)
      expect(Asimov::ApiV1::Finetunes).to have_received(:new).with(client: client)
    end
  end

  describe "#images" do
    let(:api_key) { SecureRandom.hex(4) }
    let(:client) { described_class.new(api_key: api_key) }
    let(:interface) { instance_double(Asimov::ApiV1::Images) }

    it "loads an Asimov::ApiV1::Images object initialized with the client" do
      allow(Asimov::ApiV1::Images).to receive(:new).with(client: client).and_return(interface)
      expect(client.images).to eq(interface)
      expect(Asimov::ApiV1::Images).to have_received(:new).with(client: client)
    end
  end

  describe "#models" do
    let(:api_key) { SecureRandom.hex(4) }
    let(:client) { described_class.new(api_key: api_key) }
    let(:interface) { instance_double(Asimov::ApiV1::Models) }

    it "loads an Asimov::ApiV1::Models object initialized with the client" do
      allow(Asimov::ApiV1::Models).to receive(:new).with(client: client).and_return(interface)
      expect(client.models).to eq(interface)
      expect(Asimov::ApiV1::Models).to have_received(:new).with(client: client)
    end
  end

  describe "#moderations" do
    let(:api_key) { SecureRandom.hex(4) }
    let(:client) { described_class.new(api_key: api_key) }
    let(:interface) { instance_double(Asimov::ApiV1::Moderations) }

    it "loads an Asimov::ApiV1::Moderations object initialized with the client" do
      allow(Asimov::ApiV1::Moderations).to receive(:new).with(client: client)
                                                        .and_return(interface)
      expect(client.moderations).to eq(interface)
      expect(Asimov::ApiV1::Moderations).to have_received(:new).with(client: client)
    end
  end
end
