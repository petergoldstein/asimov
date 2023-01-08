require_relative "../../spec_helper"

RSpec.describe "Models API", type: :request do
  describe "#list", :vcr do
    let(:response) { Asimov::Client.new.models.list }
    let(:cassette) { "models list" }

    it "succeeds" do
      VCR.use_cassette(cassette) do
        r = JSON.parse(response.body)
        expect(r["data"][0]["object"]).to eq("model")
      end
    end
  end

  describe "#retrieve", :vcr do
    let(:cassette) { "models retrieve" }
    let(:response) { Asimov::Client.new.models.retrieve(model_id: "text-ada-001") }

    it "succeeds" do
      VCR.use_cassette(cassette) do
        r = JSON.parse(response.body)
        expect(r["object"]).to eq("model")
      end
    end
  end
end
