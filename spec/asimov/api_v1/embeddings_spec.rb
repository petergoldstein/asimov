require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Embeddings do
  subject(:embeddings) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:model) { SecureRandom.hex(4) }
  let(:input) { SecureRandom.hex(4) }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    context "when the required model and input parameters are present" do
      let(:merged_parameters) do
        parameters.merge({
                           model: model,
                           input: input
                         })
      end

      it "calls json_post on the client with the expected arguments" do
        allow(embeddings).to receive(:json_post).with(path: "/embeddings",
                                                      parameters: merged_parameters)
                                                .and_return(ret_val)
        expect(embeddings.create(model: model, input: input, parameters: parameters)).to eq(ret_val)
        expect(embeddings).to have_received(:json_post).with(path: "/embeddings",
                                                             parameters: merged_parameters)
      end
    end

    context "when the required model parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          embeddings.create(model: nil, input: input)
        end.to raise_error Asimov::MissingRequiredParameterError

        expect do
          embeddings.create(model: nil, input: input, parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end

    context "when the required input parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          embeddings.create(model: model, input: nil)
        end.to raise_error Asimov::MissingRequiredParameterError

        expect do
          embeddings.create(model: model, input: nil, parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end

    context "when both required input parameters are missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          embeddings.create(model: nil, input: nil)
        end.to raise_error Asimov::MissingRequiredParameterError

        expect do
          embeddings.create(model: nil, input: nil, parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end
  end
end
