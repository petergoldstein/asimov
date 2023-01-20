require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Moderations do
  subject(:moderations) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:input) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    context "when the required input parameter is present" do
      let(:merged_parameters) do
        parameters.merge({ input: input })
      end

      it "calls json_post on the client with the expected arguments" do
        allow(moderations).to receive(:json_post).with(path: "/moderations",
                                                       parameters: merged_parameters)
                                                 .and_return(ret_val)
        expect(moderations.create(input: input, parameters: parameters)).to eq(ret_val)
        expect(moderations).to have_received(:json_post).with(path: "/moderations",
                                                              parameters: merged_parameters)
      end
    end

    context "when the required input parameter is nil" do
      it "raises a MissingRequiredParameterError" do
        expect do
          moderations.create(input: nil, parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end
  end
end
