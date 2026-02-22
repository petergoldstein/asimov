require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Batches do
  subject(:batches) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "batches" }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    let(:input_file_id) { "file-#{SecureRandom.hex(4)}" }
    let(:endpoint) { "/v1/chat/completions" }
    let(:completion_window) { "24h" }

    context "when required parameters are present" do
      let(:merged_params) do
        parameters.merge(
          input_file_id: input_file_id,
          endpoint: endpoint,
          completion_window: completion_window
        )
      end

      it "calls rest_create_w_json_params with the expected arguments" do
        allow(batches).to receive(:rest_create_w_json_params)
          .with(resource: resource, parameters: merged_params)
          .and_return(ret_val)
        expect(batches.create(input_file_id: input_file_id, endpoint: endpoint,
                              completion_window: completion_window,
                              parameters: parameters)).to eq(ret_val)
      end
    end

    context "when input_file_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          batches.create(input_file_id: nil, endpoint: endpoint,
                         completion_window: completion_window)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when endpoint is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          batches.create(input_file_id: input_file_id, endpoint: nil,
                         completion_window: completion_window)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when completion_window is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          batches.create(input_file_id: input_file_id, endpoint: endpoint,
                         completion_window: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#retrieve" do
    let(:batch_id) { "batch_#{SecureRandom.hex(4)}" }

    it "calls rest_get with the expected arguments" do
      allow(batches).to receive(:rest_get)
        .with(resource: resource, id: batch_id)
        .and_return(ret_val)
      expect(batches.retrieve(batch_id: batch_id)).to eq(ret_val)
    end
  end

  describe "#cancel" do
    let(:batch_id) { "batch_#{SecureRandom.hex(4)}" }

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(batches).to receive(:rest_create_w_json_params)
        .with(resource: [resource, batch_id, "cancel"], parameters: nil)
        .and_return(ret_val)
      expect(batches.cancel(batch_id: batch_id)).to eq(ret_val)
    end
  end

  describe "#list" do
    it "calls rest_index with the expected arguments" do
      allow(batches).to receive(:rest_index)
        .with(resource: resource, parameters: {})
        .and_return(ret_val)
      expect(batches.list).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "batch_abc123", limit: 10 }
      allow(batches).to receive(:rest_index)
        .with(resource: resource, parameters: pagination)
        .and_return(ret_val)
      expect(batches.list(parameters: pagination)).to eq(ret_val)
    end
  end
end
