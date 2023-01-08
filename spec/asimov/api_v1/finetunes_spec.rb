require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Finetunes do
  subject(:finetunes) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }

  it_behaves_like "sends requests to the v1 API"

  describe "#list" do
    let(:path_string) { "/fine-tunes" }

    it "calls get on the client with the expected arguments" do
      allow(finetunes).to receive(:http_get).with(path: path_string).and_return(ret_val)
      expect(finetunes.list).to eq(ret_val)
      expect(finetunes).to have_received(:http_get).with(path: path_string)
    end
  end

  describe "#create" do
    context "when the required training_file parameter is present" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), training_file: SecureRandom.hex(4) }
      end

      it "calls json_post on the client with the expected arguments" do
        allow(finetunes).to receive(:json_post).with(path: "/fine-tunes",
                                                     parameters: parameters).and_return(ret_val)
        expect(finetunes.create(parameters: parameters)).to eq(ret_val)
        expect(finetunes).to have_received(:json_post).with(path: "/fine-tunes",
                                                            parameters: parameters)
      end
    end

    context "when the required training_file parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          finetunes.create(parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end
  end

  describe "#retrieve" do
    let(:fine_tune_id) { SecureRandom.hex(4) }
    let(:path_string) { "/fine-tunes/#{fine_tune_id}" }

    it "calls get on the client with the expected arguments" do
      allow(finetunes).to receive(:http_get).with(path: path_string).and_return(ret_val)
      expect(finetunes.retrieve(fine_tune_id: fine_tune_id)).to eq(ret_val)
      expect(finetunes).to have_received(:http_get).with(path: path_string)
    end
  end

  describe "#cancel" do
    let(:fine_tune_id) { SecureRandom.hex(4) }
    let(:path_string) { "/fine-tunes/#{fine_tune_id}/cancel" }

    it "calls multipart_post on the client with the expected argument" do
      allow(finetunes).to receive(:multipart_post).with(path: path_string).and_return(ret_val)
      expect(finetunes.cancel(fine_tune_id: fine_tune_id)).to eq(ret_val)
      expect(finetunes).to have_received(:multipart_post).with(path: path_string)
    end
  end

  describe "#events" do
    let(:fine_tune_id) { SecureRandom.hex(4) }
    let(:path_string) { "/fine-tunes/#{fine_tune_id}/events" }

    it "calls get on the client with the expected argument" do
      allow(finetunes).to receive(:http_get).with(path: path_string).and_return(ret_val)
      expect(finetunes.events(fine_tune_id: fine_tune_id)).to eq(ret_val)
      expect(finetunes).to have_received(:http_get).with(path: path_string)
    end
  end
end
