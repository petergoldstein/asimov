require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Moderations do
  subject(:moderations) { described_class.new(client: client) }

  let(:access_token) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(access_token: access_token) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    context "when the required input parameter is present" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), input: SecureRandom.hex(4) }
      end

      it "calls json_post on the client with the expected arguments" do
        allow(moderations).to receive(:json_post).with(path: "/moderations",
                                                       parameters: parameters).and_return(ret_val)
        expect(moderations.create(parameters: parameters)).to eq(ret_val)
        expect(moderations).to have_received(:json_post).with(path: "/moderations",
                                                              parameters: parameters)
      end
    end

    context "when the required input parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          moderations.create(parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end
  end
end
