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
      role: %w[assistant user system].sample,
      content: Faker::Lorem.sentence
    }
  end

  def self.missing_role_chat_message
    {
      content: Faker::Lorem.sentence
    }
  end

  def self.missing_content_chat_message
    {
      role: %w[assistant user system].sample
    }
  end

  def self.extra_key_chat_message
    {
      role: %w[assistant user system].sample,
      content: Faker::Lorem.sentence,
      SecureRandom.hex(4) => SecureRandom.hex(4)
    }
  end

  def self.invalid_role_chat_message
    {
      role: SecureRandom.hex(4),
      content: Faker::Lorem.sentence
    }
  end

  def self.invalid_json_chat_message
    ".#{SecureRandom.hex(4)}"
  end

  # rubocop:disable Metrics/MethodLength
  def self.invalid_chat_message
    case rand(1..5)
    when 1
      missing_role_chat_message
    when 2
      missing_content_chat_message
    when 3
      extra_key_chat_message
    when 4
      invalid_role_chat_message
    else
      invalid_json_chat_message
    end
  end
  # rubocop:enable Metrics/MethodLength

  def self.randomize_case(str)
    str.chars.map { |c| (rand 2) == 0 ? c.downcase : c.upcase }.join
  end
end
