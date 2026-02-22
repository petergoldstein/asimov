require_relative "../spec_helper"

RSpec.describe Asimov::Configuration do
  subject(:config) { described_class.new }

  describe "#max_retries=" do
    it "accepts a non-negative integer" do
      config.max_retries = 3
      expect(config.max_retries).to eq(3)
    end

    it "accepts zero" do
      config.max_retries = 0
      expect(config.max_retries).to eq(0)
    end

    it "raises ConfigurationError for negative values" do
      expect do
        config.max_retries = -1
      end.to raise_error(Asimov::ConfigurationError, /non-negative integer/)
    end

    it "raises ConfigurationError for string values" do
      expect do
        config.max_retries = "3"
      end.to raise_error(Asimov::ConfigurationError, /non-negative integer/)
    end

    it "raises ConfigurationError for nil" do
      expect do
        config.max_retries = nil
      end.to raise_error(Asimov::ConfigurationError, /non-negative integer/)
    end

    it "raises ConfigurationError for float values" do
      expect do
        config.max_retries = 2.5
      end.to raise_error(Asimov::ConfigurationError, /non-negative integer/)
    end
  end

  describe "#log_level=" do
    %i[debug info warn error fatal].each do |level|
      it "accepts :#{level}" do
        config.log_level = level
        expect(config.log_level).to eq(level)
      end
    end

    it "raises ConfigurationError for invalid symbol" do
      expect do
        config.log_level = :verbose
      end.to raise_error(Asimov::ConfigurationError, /must be one of/)
    end

    it "raises ConfigurationError for string value" do
      expect do
        config.log_level = "info"
      end.to raise_error(Asimov::ConfigurationError, /must be one of/)
    end
  end

  describe "#request_options=" do
    it "produces a frozen hash" do
      config.request_options = { timeout: 30 }
      expect(config.request_options).to be_frozen
    end

    it "raises FrozenError when mutated" do
      config.request_options = { timeout: 30 }
      expect do
        config.request_options[:timeout] = 999
      end.to raise_error(FrozenError)
    end
  end

  describe "#reset" do
    it "restores default max_retries" do
      config.max_retries = 5
      config.reset
      expect(config.max_retries).to eq(0)
    end

    it "restores default log_level" do
      config.log_level = :debug
      config.reset
      expect(config.log_level).to eq(:info)
    end

    it "restores a frozen empty request_options" do
      config.request_options = { timeout: 30 }
      config.reset
      expect(config.request_options).to eq({})
      expect(config.request_options).to be_frozen
    end
  end
end
