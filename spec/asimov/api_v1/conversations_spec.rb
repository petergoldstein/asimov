require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Conversations do
  subject(:conversations) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:resource) { "conversations" }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    it "calls rest_create_w_json_params with the expected arguments" do
      allow(conversations).to receive(:rest_create_w_json_params)
        .with(resource: resource, parameters: parameters)
        .and_return(ret_val)
      expect(conversations.create(parameters: parameters)).to eq(ret_val)
    end

    it "defaults to empty parameters" do
      allow(conversations).to receive(:rest_create_w_json_params)
        .with(resource: resource, parameters: {})
        .and_return(ret_val)
      expect(conversations.create).to eq(ret_val)
    end
  end

  describe "#list" do
    it "calls rest_index with the expected arguments" do
      allow(conversations).to receive(:rest_index)
        .with(resource: resource, parameters: {})
        .and_return(ret_val)
      expect(conversations.list).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "conv_abc123", limit: 20 }
      allow(conversations).to receive(:rest_index)
        .with(resource: resource, parameters: pagination)
        .and_return(ret_val)
      expect(conversations.list(parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#retrieve" do
    let(:conversation_id) { "conv_#{SecureRandom.hex(4)}" }

    context "when conversation_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          conversations.retrieve(conversation_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(conversations).to receive(:rest_get)
        .with(resource: resource, id: conversation_id)
        .and_return(ret_val)
      expect(conversations.retrieve(conversation_id: conversation_id)).to eq(ret_val)
    end
  end

  describe "#update" do
    let(:conversation_id) { "conv_#{SecureRandom.hex(4)}" }

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(conversations).to receive(:rest_create_w_json_params)
        .with(resource: [resource, conversation_id], parameters: parameters)
        .and_return(ret_val)
      expect(conversations.update(conversation_id: conversation_id,
                                  parameters: parameters)).to eq(ret_val)
    end

    it "defaults to empty parameters" do
      allow(conversations).to receive(:rest_create_w_json_params)
        .with(resource: [resource, conversation_id], parameters: {})
        .and_return(ret_val)
      expect(conversations.update(conversation_id: conversation_id)).to eq(ret_val)
    end

    context "when conversation_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          conversations.update(conversation_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#delete" do
    let(:conversation_id) { "conv_#{SecureRandom.hex(4)}" }

    context "when conversation_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          conversations.delete(conversation_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(conversations).to receive(:rest_delete)
        .with(resource: resource, id: conversation_id)
        .and_return(ret_val)
      expect(conversations.delete(conversation_id: conversation_id)).to eq(ret_val)
    end
  end

  describe "#create_items" do
    let(:conversation_id) { "conv_#{SecureRandom.hex(4)}" }
    let(:items) { [{ type: "message", role: "user", content: "Hello" }] }

    it "calls rest_create_w_json_params with items merged into parameters" do
      merged = { items: items }.merge(parameters)
      allow(conversations).to receive(:rest_create_w_json_params)
        .with(resource: [resource, conversation_id, "items"], parameters: merged)
        .and_return(ret_val)
      expect(conversations.create_items(conversation_id: conversation_id, items: items,
                                        parameters: parameters)).to eq(ret_val)
    end

    it "defaults to only items in parameters" do
      allow(conversations).to receive(:rest_create_w_json_params)
        .with(resource: [resource, conversation_id, "items"], parameters: { items: items })
        .and_return(ret_val)
      expect(conversations.create_items(conversation_id: conversation_id,
                                        items: items)).to eq(ret_val)
    end

    context "when conversation_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          conversations.create_items(conversation_id: nil, items: items)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#retrieve_item" do
    let(:conversation_id) { "conv_#{SecureRandom.hex(4)}" }
    let(:item_id) { "item_#{SecureRandom.hex(4)}" }

    context "when conversation_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          conversations.retrieve_item(conversation_id: nil, item_id: item_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when item_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          conversations.retrieve_item(conversation_id: conversation_id, item_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(conversations).to receive(:rest_index)
        .with(resource: [resource, conversation_id, "items", item_id], parameters: {})
        .and_return(ret_val)
      expect(conversations.retrieve_item(conversation_id: conversation_id,
                                         item_id: item_id)).to eq(ret_val)
    end
  end

  describe "#list_items" do
    let(:conversation_id) { "conv_#{SecureRandom.hex(4)}" }

    context "when conversation_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          conversations.list_items(conversation_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(conversations).to receive(:rest_index)
        .with(resource: [resource, conversation_id, "items"], parameters: {})
        .and_return(ret_val)
      expect(conversations.list_items(conversation_id: conversation_id)).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "item_abc123", limit: 20 }
      allow(conversations).to receive(:rest_index)
        .with(resource: [resource, conversation_id, "items"], parameters: pagination)
        .and_return(ret_val)
      expect(conversations.list_items(conversation_id: conversation_id,
                                      parameters: pagination)).to eq(ret_val)
    end
  end

  describe "#delete_item" do
    let(:conversation_id) { "conv_#{SecureRandom.hex(4)}" }
    let(:item_id) { "item_#{SecureRandom.hex(4)}" }

    context "when conversation_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          conversations.delete_item(conversation_id: nil, item_id: item_id)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    context "when item_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          conversations.delete_item(conversation_id: conversation_id, item_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(conversations).to receive(:rest_delete)
        .with(resource: "conversations/#{conversation_id}/items", id: item_id)
        .and_return(ret_val)
      expect(conversations.delete_item(conversation_id: conversation_id,
                                       item_id: item_id)).to eq(ret_val)
    end
  end
end
