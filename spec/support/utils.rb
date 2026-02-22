module Utils
  def self.reset_global_configuration
    Asimov.configuration.reset
  end

  def self.load_global_configuration
    default_token = ENV["RUN_LIVE"] ? nil : "notarealaccesstoken"
    Asimov.configure do |config|
      config.api_key = ENV.fetch("OPENAI_API_KEY", default_token)
    end
  end

  def self.fixture_filename(filename:)
    File.join(RSPEC_ROOT, "fixtures/files", filename)
  end

  def self.valid_chat_message
    {
      role: %w[assistant user system developer tool].sample,
      content: Faker::Lorem.sentence
    }
  end

  def self.missing_role_chat_message
    {
      content: Faker::Lorem.sentence
    }
  end

  def self.invalid_json_chat_message
    ".#{SecureRandom.hex(4)}"
  end

  def self.invalid_chat_message
    [missing_role_chat_message, invalid_json_chat_message].sample
  end
end
