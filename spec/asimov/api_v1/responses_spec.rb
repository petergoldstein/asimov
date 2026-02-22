require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Responses do
  subject(:responses) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "responses" }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    let(:model) { "gpt-4o" }
    let(:input) { "Explain quantum computing" }

    context "when required parameters are present" do
      let(:merged_params) { parameters.merge(model: model, input: input) }

      it "calls rest_create_w_json_params with the expected arguments" do
        allow(responses).to receive(:rest_create_w_json_params)
          .with(resource: resource, parameters: merged_params)
          .and_return(ret_val)
        expect(responses.create(model: model, input: input,
                                parameters: parameters)).to eq(ret_val)
      end
    end

    context "when streaming with a block" do
      let(:merged_params) { parameters.merge(model: model, input: input, stream: true) }

      it "calls rest_create_w_json_params_streamed" do
        allow(responses).to receive(:rest_create_w_json_params_streamed)
          .with(resource: resource, parameters: merged_params)
          .and_return(ret_val)
        result = responses.create(model: model, input: input,
                                  parameters: parameters) { |chunk| chunk }
        expect(result).to eq(ret_val)
      end
    end

    context "when model is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          responses.create(model: nil, input: input)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when input is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          responses.create(model: model, input: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#retrieve" do
    let(:response_id) { "resp_#{SecureRandom.hex(4)}" }

    context "when response_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          responses.retrieve(response_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(responses).to receive(:rest_get)
        .with(resource: resource, id: response_id)
        .and_return(ret_val)
      expect(responses.retrieve(response_id: response_id)).to eq(ret_val)
    end
  end

  describe "#delete" do
    let(:response_id) { "resp_#{SecureRandom.hex(4)}" }

    context "when response_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          responses.delete(response_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(responses).to receive(:rest_delete)
        .with(resource: resource, id: response_id)
        .and_return(ret_val)
      expect(responses.delete(response_id: response_id)).to eq(ret_val)
    end
  end

  describe "#cancel" do
    let(:response_id) { "resp_#{SecureRandom.hex(4)}" }

    context "when response_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          responses.cancel(response_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(responses).to receive(:rest_create_w_json_params)
        .with(resource: [resource, response_id, "cancel"], parameters: nil)
        .and_return(ret_val)
      expect(responses.cancel(response_id: response_id)).to eq(ret_val)
    end
  end

  describe "#compact" do
    let(:model) { "gpt-4o" }

    it "calls rest_create_w_json_params with model merged into parameters" do
      merged = { model: model }.merge(parameters)
      allow(responses).to receive(:rest_create_w_json_params)
        .with(resource: [resource, "compact"], parameters: merged)
        .and_return(ret_val)
      expect(responses.compact(model: model, parameters: parameters)).to eq(ret_val)
    end

    it "defaults to only model in parameters" do
      allow(responses).to receive(:rest_create_w_json_params)
        .with(resource: [resource, "compact"], parameters: { model: model })
        .and_return(ret_val)
      expect(responses.compact(model: model)).to eq(ret_val)
    end
  end

  describe "#count_input_tokens" do
    it "calls rest_create_w_json_params with the expected arguments" do
      allow(responses).to receive(:rest_create_w_json_params)
        .with(resource: [resource, "input_tokens"], parameters: parameters)
        .and_return(ret_val)
      expect(responses.count_input_tokens(parameters: parameters)).to eq(ret_val)
    end

    it "defaults to empty parameters" do
      allow(responses).to receive(:rest_create_w_json_params)
        .with(resource: [resource, "input_tokens"], parameters: {})
        .and_return(ret_val)
      expect(responses.count_input_tokens).to eq(ret_val)
    end
  end

  describe "#list_input_items" do
    let(:response_id) { "resp_#{SecureRandom.hex(4)}" }

    context "when response_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          responses.list_input_items(response_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(responses).to receive(:rest_index)
        .with(resource: [resource, response_id, "input_items"], parameters: {})
        .and_return(ret_val)
      expect(responses.list_input_items(response_id: response_id)).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "item_abc123", limit: 20 }
      allow(responses).to receive(:rest_index)
        .with(resource: [resource, response_id, "input_items"], parameters: pagination)
        .and_return(ret_val)
      expect(responses.list_input_items(response_id: response_id,
                                        parameters: pagination)).to eq(ret_val)
    end
  end
end
