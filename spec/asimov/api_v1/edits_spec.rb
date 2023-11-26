require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Edits do
  subject(:edits) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:model) { SecureRandom.hex(4) }
  let(:instruction) { SecureRandom.hex(4) }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    context "when using an OpenAI endpoint client" do
      let(:client) { Asimov::Client.new(api_key: api_key) }

      context "when the required model and instruction parameters are present" do
        let(:merged_params) do
          parameters.merge({ model: model,
                             instruction: instruction })
        end

        it "calls rest_create_w_json_params on the client with the expected arguments" do
          allow(edits).to receive(:rest_create_w_json_params).with(resource: "edits",
                                                                   parameters: merged_params)
                                                             .and_return(ret_val)
          expect(edits.create(model: model, instruction: instruction,
                              parameters: parameters)).to eq(ret_val)
          expect(edits).to have_received(:rest_create_w_json_params).with(resource: "edits",
                                                                          parameters: merged_params)
        end
      end

      context "when the required model parameter is missing" do
        it "raises a MissingRequiredParameterError" do
          expect do
            edits.create(model: nil, instruction: instruction)
          end.to raise_error Asimov::MissingRequiredParameterError

          expect do
            edits.create(model: nil, instruction: instruction, parameters: parameters)
          end.to raise_error Asimov::MissingRequiredParameterError
        end
      end

      context "when the required instruction parameter is missing" do
        it "raises a MissingRequiredParameterError" do
          expect do
            edits.create(model: model, instruction: nil)
          end.to raise_error Asimov::MissingRequiredParameterError

          expect do
            edits.create(model: model, instruction: nil, parameters: parameters)
          end.to raise_error Asimov::MissingRequiredParameterError
        end
      end

      context "when both required input parameters are missing" do
        it "raises a MissingRequiredParameterError" do
          expect do
            edits.create(model: nil, instruction: nil)
          end.to raise_error Asimov::MissingRequiredParameterError

          expect do
            edits.create(model: nil, instruction: nil, parameters: parameters)
          end.to raise_error Asimov::MissingRequiredParameterError
        end
      end
    end

    context "when using an Azure client" do
      let(:client) { Asimov::Client.new(api_type: "azure", api_key: api_key) }

      context "when the required model and instruction parameters are present" do
        it "raises an error and does not post" do
          allow(edits).to receive(:rest_create_w_json_params)
          expect do
            edits.create(model: model, instruction: instruction,
                         parameters: parameters)
          end.to raise_error Asimov::InvalidApiTypeError
          expect(edits).not_to have_received(:rest_create_w_json_params)
        end
      end
    end

    context "when using an Azure AD client" do
      let(:client) { Asimov::Client.new(api_type: "azure_ad", api_key: api_key) }

      context "when the required model and instruction parameters are present" do
        it "raises an error and does not post" do
          allow(edits).to receive(:rest_create_w_json_params)
          expect do
            edits.create(model: model, instruction: instruction,
                         parameters: parameters)
          end.to raise_error Asimov::InvalidApiTypeError
          expect(edits).not_to have_received(:rest_create_w_json_params)
        end
      end
    end
  end
end
