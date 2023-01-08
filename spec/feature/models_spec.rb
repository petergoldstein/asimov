require_relative "../spec_helper"

RSpec.describe "Models API", type: :feature do
  describe "list all models", :vcr do
    let(:response) { Asimov::Client.new.models.list }
    let(:cassette) { "models list" }

    it "succeeds" do
      VCR.use_cassette(cassette) do
        expect(response["data"][0]["object"]).to eq("model")
      end
    end
  end

  describe "retrieve a model by id", :vcr do
    let(:cassette) { "models retrieve" }
    let(:response) { Asimov::Client.new.models.retrieve(model_id: "text-ada-001") }

    it "succeeds" do
      VCR.use_cassette(cassette) do
        expect(response["object"]).to eq("model")
      end
    end
  end

  describe "retrieving a model that does not exist", :vcr do
    let(:client) { Asimov::Client.new }

    it "generates the expected error" do
      VCR.use_cassette("models retrieve with non-existent id") do
        expect do
          client.models.retrieve(model_id: "nosuchmodel")
        end.to raise_error(Asimov::NotFoundError)
      end
    end
  end

  describe "deleting a model that does not exist", :vcr do
    let(:client) { Asimov::Client.new }

    it "generates the expected error" do
      VCR.use_cassette("models delete with non-existent id") do
        expect do
          client.models.retrieve(model_id: "nosuchmodel")
        end.to raise_error(Asimov::NotFoundError)
      end
    end
  end
end
