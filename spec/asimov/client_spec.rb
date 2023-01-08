require_relative "../spec_helper"

RSpec.describe Asimov::Client do
  describe ".initialize" do
    let(:per_client_access_token) { SecureRandom.hex(4) }
    let(:per_client_organization_id) { SecureRandom.hex(4) }

    context "when the global configuration includes an access token" do
      let(:global_access_token) { SecureRandom.hex(4) }
      let(:global_organization_id) { SecureRandom.hex(4) }

      context "when the global configuration does not include an organization_id" do
        before do
          Asimov.configure do |config|
            config.access_token = global_access_token
          end
        end

        it "can be initialized with no arguments and sets values from the global configuration" do
          client = nil
          expect do
            client = described_class.new
          end.not_to raise_error
          expect(client.access_token).to eq(global_access_token)
          expect(client.organization_id).to be_nil
        end

        it "allows override of the global access token" do
          client = nil
          expect do
            client = described_class.new(access_token: per_client_access_token)
          end.not_to raise_error
          expect(client.access_token).to eq(per_client_access_token)
          expect(client.organization_id).to be_nil
        end

        it "allows setting of an organization_id with the access_token" do
          client = nil
          expect do
            client = described_class.new(access_token: per_client_access_token,
                                         organization_id: per_client_organization_id)
          end.not_to raise_error
          expect(client.access_token).to eq(per_client_access_token)
          expect(client.organization_id).to eq(per_client_organization_id)
        end
      end

      context "when the global configuration includes an organization_id" do
        before do
          Asimov.configure do |config|
            config.access_token = global_access_token
            config.organization_id = global_organization_id
          end
        end

        it "can be initialized with no arguments and sets values from the global configuration" do
          client = nil
          expect do
            client = described_class.new
          end.not_to raise_error
          expect(client.access_token).to eq(global_access_token)
          expect(client.organization_id).to eq(global_organization_id)
        end

        it "allows override of the global configuration with a nil organization id" do
          client = nil
          expect do
            client = described_class.new(organization_id: nil)
          end.not_to raise_error
          expect(client.access_token).to eq(global_access_token)
          expect(client.organization_id).to be_nil
        end

        it "allows override of the global configuration with a different organization id" do
          client = nil
          expect do
            client = described_class.new(organization_id: per_client_organization_id)
          end.not_to raise_error
          expect(client.access_token).to eq(global_access_token)
          expect(client.organization_id).to eq(per_client_organization_id)
        end

        it "allows override of the global configuration with a nil organization id in tandem " \
           "with a per client access token" do
          client = nil
          expect do
            client = described_class.new(access_token: per_client_access_token,
                                         organization_id: nil)
          end.not_to raise_error
          expect(client.access_token).to eq(per_client_access_token)
          expect(client.organization_id).to be_nil
        end

        it "allows override of the global configuration with a different organization id with " \
           "a per client access token" do
          client = nil
          expect do
            client = described_class.new(access_token: per_client_access_token,
                                         organization_id: per_client_organization_id)
          end.not_to raise_error
          expect(client.access_token).to eq(per_client_access_token)
          expect(client.organization_id).to eq(per_client_organization_id)
        end
      end
    end

    context "when the global configuration does not include an access token" do
      it "raises an error when initialized with no arguments" do
        expect do
          described_class.new
        end.to raise_error(Asimov::MissingAccessTokenError)
      end

      it "initializes successfully when passed an access_token" do
        client = nil
        expect do
          client = described_class.new(access_token: per_client_access_token)
        end.not_to raise_error
        expect(client.access_token).to eq(per_client_access_token)
        expect(client.organization_id).to be_nil
      end

      it "allows the client to set a per-client organization_id" do
        client = nil
        expect do
          client = described_class.new(access_token: per_client_access_token,
                                       organization_id: per_client_organization_id)
        end.not_to raise_error
        expect(client.access_token).to eq(per_client_access_token)
        expect(client.organization_id).to eq(per_client_organization_id)
      end
    end
  end

  describe "#completions" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { described_class.new(access_token: access_token) }
    let(:interface) { instance_double(Asimov::ApiV1::Completions) }

    it "loads an Asimov::ApiV1::Completions object initialized with the client" do
      allow(Asimov::ApiV1::Completions).to receive(:new).with(client: client)
                                                        .and_return(interface)
      expect(client.completions).to eq(interface)
      expect(Asimov::ApiV1::Completions).to have_received(:new).with(client: client)
    end
  end

  describe "#edits" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { described_class.new(access_token: access_token) }
    let(:interface) { instance_double(Asimov::ApiV1::Edits) }

    it "loads an Asimov::ApiV1::Edits object initialized with the client" do
      allow(Asimov::ApiV1::Edits).to receive(:new).with(client: client).and_return(interface)
      expect(client.edits).to eq(interface)
      expect(Asimov::ApiV1::Edits).to have_received(:new).with(client: client)
    end
  end

  describe "#embeddings" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { described_class.new(access_token: access_token) }
    let(:interface) { instance_double(Asimov::ApiV1::Embeddings) }

    it "loads an Asimov::ApiV1::Embeddings object initialized with the client" do
      allow(Asimov::ApiV1::Embeddings).to receive(:new).with(client: client)
                                                       .and_return(interface)
      expect(client.embeddings).to eq(interface)
      expect(Asimov::ApiV1::Embeddings).to have_received(:new).with(client: client)
    end
  end

  describe "#files" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { described_class.new(access_token: access_token) }
    let(:interface) { instance_double(Asimov::ApiV1::Files) }

    it "loads an Asimov::ApiV1::Files object initialized with the client" do
      allow(Asimov::ApiV1::Files).to receive(:new).with(client: client).and_return(interface)
      expect(client.files).to eq(interface)
      expect(Asimov::ApiV1::Files).to have_received(:new).with(client: client)
    end
  end

  describe "#finetunes" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { described_class.new(access_token: access_token) }
    let(:interface) { instance_double(Asimov::ApiV1::Finetunes) }

    it "loads an Asimov::ApiV1::Finetunes object initialized with the client" do
      allow(Asimov::ApiV1::Finetunes).to receive(:new).with(client: client)
                                                      .and_return(interface)
      expect(client.finetunes).to eq(interface)
      expect(Asimov::ApiV1::Finetunes).to have_received(:new).with(client: client)
    end
  end

  describe "#images" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { described_class.new(access_token: access_token) }
    let(:interface) { instance_double(Asimov::ApiV1::Images) }

    it "loads an Asimov::ApiV1::Images object initialized with the client" do
      allow(Asimov::ApiV1::Images).to receive(:new).with(client: client).and_return(interface)
      expect(client.images).to eq(interface)
      expect(Asimov::ApiV1::Images).to have_received(:new).with(client: client)
    end
  end

  describe "#models" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { described_class.new(access_token: access_token) }
    let(:interface) { instance_double(Asimov::ApiV1::Models) }

    it "loads an Asimov::ApiV1::Models object initialized with the client" do
      allow(Asimov::ApiV1::Models).to receive(:new).with(client: client).and_return(interface)
      expect(client.models).to eq(interface)
      expect(Asimov::ApiV1::Models).to have_received(:new).with(client: client)
    end
  end

  describe "#moderations" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { described_class.new(access_token: access_token) }
    let(:interface) { instance_double(Asimov::ApiV1::Moderations) }

    it "loads an Asimov::ApiV1::Moderations object initialized with the client" do
      allow(Asimov::ApiV1::Moderations).to receive(:new).with(client: client)
                                                        .and_return(interface)
      expect(client.moderations).to eq(interface)
      expect(Asimov::ApiV1::Moderations).to have_received(:new).with(client: client)
    end
  end
end
