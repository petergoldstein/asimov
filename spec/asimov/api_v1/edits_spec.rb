require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Edits do
  subject(:edits) { described_class.new(client: client) }

  let(:access_token) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(access_token: access_token) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    context "when the required model and instruction parameters are present" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          model: SecureRandom.hex(4),
          instruction: SecureRandom.hex(4) }
      end

      it "calls json_post on the client with the expected arguments" do
        allow(edits).to receive(:json_post).with(path: "/edits",
                                                 parameters: parameters).and_return(ret_val)
        expect(edits.create(parameters: parameters)).to eq(ret_val)
        expect(edits).to have_received(:json_post).with(path: "/edits", parameters: parameters)
      end
    end

    context "when the required model parameter is missing" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          instruction: SecureRandom.hex(4) }
      end

      it "raises a MissingRequiredParameterError" do
        expect do
          edits.create(parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end

    context "when the required instruction parameter is missing" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          model: SecureRandom.hex(4) }
      end

      it "raises a MissingRequiredParameterError" do
        expect do
          edits.create(parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end

    context "when both required input parameters are missing" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) }
      end

      it "raises a MissingRequiredParameterError" do
        expect do
          edits.create(parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end
  end
end
