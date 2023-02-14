require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Finetunes do
  subject(:finetunes) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "fine-tunes" }

  it_behaves_like "sends requests to the v1 API"

  describe "#list" do
    it "calls get on the client with the expected arguments" do
      allow(finetunes).to receive(:rest_index).with(resource: resource).and_return(ret_val)
      expect(finetunes.list).to eq(ret_val)
      expect(finetunes).to have_received(:rest_index).with(resource: resource)
    end
  end

  describe "#create" do
    let(:training_file_id) { SecureRandom.hex(5) }

    context "when the required training_file parameter is present" do
      let(:merged_params) do
        parameters.merge(training_file: training_file_id)
      end

      it "calls rest_create_w_json_params on the client with the expected arguments" do
        allow(finetunes).to receive(:rest_create_w_json_params).with(resource: "fine-tunes",
                                                                     parameters: merged_params)
                                                               .and_return(ret_val)
        expect(finetunes.create(training_file: training_file_id,
                                parameters: parameters)).to eq(ret_val)
        expect(finetunes).to have_received(:rest_create_w_json_params)
          .with(resource: "fine-tunes",
                parameters: merged_params)
      end
    end

    context "when the required training_file parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          finetunes.create(training_file: nil, parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end
  end

  describe "#retrieve" do
    let(:fine_tune_id) { SecureRandom.hex(4) }

    it "calls get on the client with the expected arguments" do
      allow(finetunes).to receive(:rest_get).with(resource: resource,
                                                  id: fine_tune_id).and_return(ret_val)
      expect(finetunes.retrieve(fine_tune_id: fine_tune_id)).to eq(ret_val)
      expect(finetunes).to have_received(:rest_get).with(resource: resource, id: fine_tune_id)
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

    it "calls get on the client with the expected argument" do
      allow(finetunes).to receive(:rest_index).with(resource: [resource, fine_tune_id,
                                                               "events"]).and_return(ret_val)
      expect(finetunes.list_events(fine_tune_id: fine_tune_id)).to eq(ret_val)
      expect(finetunes).to have_received(:rest_index).with(resource: [resource, fine_tune_id,
                                                                      "events"])
    end
  end
end
