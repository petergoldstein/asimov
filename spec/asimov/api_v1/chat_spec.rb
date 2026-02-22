require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Chat do
  subject(:chat) { described_class.new(client: client) }

  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:api_key) { SecureRandom.hex(4) }
  let(:model) { SecureRandom.hex(4) }
  let(:resource) { "chat" }
  let(:messages) { Array.new(rand(1..10)) { Utils.valid_chat_message } }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    context "when the required model parameter is present" do
      let(:merged_params) do
        parameters.merge(
          { model: model,
            messages: messages.map { |m| m.transform_keys(&:to_s) } }
        )
      end

      context "when the required messages parameter is present" do
        context "when the messages parameter is valid" do
          context "without a block (non-streaming)" do
            it "calls rest_create_w_json_params on the client with the expected arguments" do
              allow(chat).to receive(:rest_create_w_json_params)
                .with(resource: [resource, "completions"],
                      parameters: merged_params)
                .and_return(ret_val)
              expect(chat.create(model: model, messages: messages,
                                 parameters: parameters)).to eq(ret_val)
              expect(chat).to have_received(:rest_create_w_json_params)
                .with(resource: [resource, "completions"],
                      parameters: merged_params)
            end
          end

          context "with a block (streaming)" do
            let(:streamed_params) { merged_params.merge(stream: true) }

            it "calls rest_create_w_json_params_streamed with stream: true" do
              allow(chat).to receive(:rest_create_w_json_params_streamed)
              block = proc { |_chunk| }
              chat.create(model: model, messages: messages,
                          parameters: parameters, &block)
              expect(chat).to have_received(:rest_create_w_json_params_streamed)
                .with(resource: [resource, "completions"],
                      parameters: streamed_params)
            end
          end
        end

        context "when the messages parameter is not valid" do
          let(:messages) { Array.new(rand(1..10)) { Utils.invalid_chat_message } }

          it "raises an error" do
            expect do
              chat.create(model: model, messages: messages, parameters: parameters)
            end.to raise_error(Asimov::InvalidChatMessagesError)
          end
        end
      end

      context "when the required messages parameter is missing" do
        it "raises a MissingRequiredParameterError" do
          expect do
            chat.create(model: model, messages: nil)
          end.to raise_error Asimov::MissingRequiredParameterError

          expect do
            chat.create(model: model, messages: nil, parameters: parameters)
          end.to raise_error Asimov::MissingRequiredParameterError
        end
      end
    end

    context "when the required model parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          chat.create(model: nil, messages: messages)
        end.to raise_error Asimov::MissingRequiredParameterError

        expect do
          chat.create(model: nil, messages: messages, parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end
  end

  describe "#retrieve" do
    let(:completion_id) { "chatcmpl-#{SecureRandom.hex(4)}" }

    context "when completion_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          chat.retrieve(completion_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_get with the expected arguments" do
      allow(chat).to receive(:rest_get)
        .with(resource: "chat/completions", id: completion_id)
        .and_return(ret_val)
      expect(chat.retrieve(completion_id: completion_id)).to eq(ret_val)
    end
  end

  describe "#update" do
    let(:completion_id) { "chatcmpl-#{SecureRandom.hex(4)}" }

    context "when completion_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          chat.update(completion_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_create_w_json_params with the expected arguments" do
      allow(chat).to receive(:rest_create_w_json_params)
        .with(resource: [resource, "completions", completion_id], parameters: parameters)
        .and_return(ret_val)
      expect(chat.update(completion_id: completion_id, parameters: parameters)).to eq(ret_val)
    end

    it "defaults to empty parameters" do
      allow(chat).to receive(:rest_create_w_json_params)
        .with(resource: [resource, "completions", completion_id], parameters: {})
        .and_return(ret_val)
      expect(chat.update(completion_id: completion_id)).to eq(ret_val)
    end
  end

  describe "#delete" do
    let(:completion_id) { "chatcmpl-#{SecureRandom.hex(4)}" }

    context "when completion_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          chat.delete(completion_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_delete with the expected arguments" do
      allow(chat).to receive(:rest_delete)
        .with(resource: "chat/completions", id: completion_id)
        .and_return(ret_val)
      expect(chat.delete(completion_id: completion_id)).to eq(ret_val)
    end
  end

  describe "#list" do
    it "calls rest_index with the expected arguments" do
      allow(chat).to receive(:rest_index)
        .with(resource: [resource, "completions"], parameters: {})
        .and_return(ret_val)
      expect(chat.list).to eq(ret_val)
    end

    it "passes query parameters" do
      query = { model: "gpt-4o", limit: 10 }
      allow(chat).to receive(:rest_index)
        .with(resource: [resource, "completions"], parameters: query)
        .and_return(ret_val)
      expect(chat.list(parameters: query)).to eq(ret_val)
    end
  end

  describe "#list_messages" do
    let(:completion_id) { "chatcmpl-#{SecureRandom.hex(4)}" }

    context "when completion_id is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          chat.list_messages(completion_id: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end

    it "calls rest_index with the expected arguments" do
      allow(chat).to receive(:rest_index)
        .with(resource: [resource, "completions", completion_id, "messages"], parameters: {})
        .and_return(ret_val)
      expect(chat.list_messages(completion_id: completion_id)).to eq(ret_val)
    end

    it "passes pagination parameters" do
      pagination = { after: "msg_abc123", limit: 20 }
      allow(chat).to receive(:rest_index)
        .with(resource: [resource, "completions", completion_id, "messages"],
              parameters: pagination)
        .and_return(ret_val)
      expect(chat.list_messages(completion_id: completion_id,
                                parameters: pagination)).to eq(ret_val)
    end
  end
end
