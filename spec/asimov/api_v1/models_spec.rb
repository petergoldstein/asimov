require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Models do
  subject(:models) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:resource) { "models" }

  it_behaves_like "sends requests to the v1 API"

  describe "#list" do
    it "calls get on the client with the expected argument" do
      allow(models).to receive(:rest_index).with(resource: resource).and_return(ret_val)
      expect(models.list).to eq(ret_val)
      expect(models).to have_received(:rest_index).with(resource: resource)
    end
  end

  describe "#retrieve" do
    let(:model_id) { SecureRandom.hex(4) }
    let(:path_string) { "/models/#{model_id}" }

    it "calls get on the client with the expected argument" do
      allow(models).to receive(:rest_get).with(resource: resource, id: model_id)
                                         .and_return(ret_val)
      expect(models.retrieve(model_id: model_id)).to eq(ret_val)
      expect(models).to have_received(:rest_get).with(resource: resource, id: model_id)
    end
  end

  describe "#delete" do
    let(:model_id) { SecureRandom.hex(4) }

    it "calls delete on the client with the expected arguments" do
      allow(models).to receive(:rest_delete).with(resource: resource, id: model_id)
                                            .and_return(ret_val)
      expect(models.delete(model_id: model_id)).to eq(ret_val)
      expect(models).to have_received(:rest_delete).with(resource: resource, id: model_id)
    end
  end
end
