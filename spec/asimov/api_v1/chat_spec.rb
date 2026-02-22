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
end
