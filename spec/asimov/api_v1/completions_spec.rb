require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Completions do
  subject(:completions) { described_class.new(client: client) }

  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:api_key) { SecureRandom.hex(4) }
  let(:model) { SecureRandom.hex(4) }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    let(:client) { Asimov::Client.new(api_key: api_key) }

    context "when using an OpenAI endpoint client" do
      context "when the required model parameter is present" do
        let(:merged_params) do
          parameters.merge({ model: model })
        end

        it "calls rest_create_w_json_params on the client with the expected arguments" do
          allow(completions).to receive(:rest_create_w_json_params)
            .with(resource: "completions",
                  parameters: merged_params)
            .and_return(ret_val)
          expect(completions.create(model: model, parameters: parameters)).to eq(ret_val)
          expect(completions).to have_received(:rest_create_w_json_params)
            .with(resource: "completions",
                  parameters: merged_params)
        end
      end

      context "when the required model parameter is missing" do
        it "raises a MissingRequiredParameterError" do
          expect do
            completions.create(model: nil)
          end.to raise_error Asimov::MissingRequiredParameterError

          expect do
            completions.create(model: nil, parameters: parameters)
          end.to raise_error Asimov::MissingRequiredParameterError
        end
      end
    end
  end
end
