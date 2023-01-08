require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Models do
  subject(:models) { described_class.new(client: client) }

  let(:client) { instance_double(Asimov::Client) }
  let(:ret_val) { SecureRandom.hex(4) }

  describe "#list" do
    it "calls get on the client with the expected argument" do
      allow(client).to receive(:http_get).with(path: "/v1/models").and_return(ret_val)
      expect(models.list).to eq(ret_val)
      expect(client).to have_received(:http_get).with(path: "/v1/models")
    end
  end

  describe "#retrieve" do
    let(:model_id) { SecureRandom.hex(4) }
    let(:path_string) { "/v1/models/#{model_id}" }

    it "calls get on the client with the expected argument" do
      allow(client).to receive(:http_get).with(path: path_string).and_return(ret_val)
      expect(models.retrieve(model_id: model_id)).to eq(ret_val)
      expect(client).to have_received(:http_get).with(path: path_string)
    end
  end

  describe "#delete" do
    let(:model_id) { SecureRandom.hex(4) }
    let(:path_string) { "/v1/models/#{model_id}" }

    it "calls delete on the client with the expected arguments" do
      allow(client).to receive(:http_delete).with(path: path_string).and_return(ret_val)
      expect(models.delete(model_id: model_id)).to eq(ret_val)
      expect(client).to have_received(:http_delete).with(path: path_string)
    end
  end
end
