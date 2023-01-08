require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Embeddings do
  subject(:embeddings) { described_class.new(client: client) }

  let(:access_token) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(access_token: access_token) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    context "when the required model and input parameters are present" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          model: SecureRandom.hex(4),
          input: SecureRandom.hex(4) }
      end

      it "calls json_post on the client with the expected arguments" do
        allow(embeddings).to receive(:json_post).with(path: "/embeddings",
                                                      parameters: parameters).and_return(ret_val)
        expect(embeddings.create(parameters: parameters)).to eq(ret_val)
        expect(embeddings).to have_received(:json_post).with(path: "/embeddings",
                                                             parameters: parameters)
      end
    end

    context "when the required model parameter is missing" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          input: SecureRandom.hex(4) }
      end

      it "raises a MissingRequiredParameterError" do
        expect do
          embeddings.create(parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end

    context "when the required input parameter is missing" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          model: SecureRandom.hex(4) }
      end

      it "raises a MissingRequiredParameterError" do
        expect do
          embeddings.create(parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end

    context "when both required input parameters are missing" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) }
      end

      it "raises a MissingRequiredParameterError" do
        expect do
          embeddings.create(parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end
  end
end
