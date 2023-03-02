require_relative "../../spec_helper"

RSpec.describe Asimov::Utils::ChatMessagesValidator do
  describe ".validate" do
    subject(:instance) { described_class.new }

    context "when passed a valid set of messages" do
      let(:messages) { Array.new(rand(1..10)) { Utils.valid_chat_message } }

      it "does not raise an error" do
        expect { instance.validate(messages) }.not_to raise_error
      end
    end

    context "when passed set of messages including an invalid message" do
      let(:invalid_chat_message) do
        [
          Utils.missing_role_chat_message,
          Utils.missing_content_chat_message,
          Utils.extra_key_chat_message,
          Utils.invalid_role_chat_message,
          Utils.invalid_json_chat_message
        ].sample
      end

      let(:messages) do
        msgs = Array.new(rand(1..10)) { Utils.valid_chat_message }
        msgs << invalid_chat_message
        msgs.shuffle
        msgs
      end

      it "raises an error" do
        expect { instance.validate(messages) }.to raise_error(Asimov::InvalidChatMessagesError)
      end
    end

    context "when passed nil" do
      it "raises an error" do
        expect { instance.validate(nil) }.to raise_error(Asimov::InvalidChatMessagesError)
      end
    end

    context "when passed an empty array" do
      it "does not raise an error" do
        expect { instance.validate([]) }.not_to raise_error
      end
    end
  end
end
