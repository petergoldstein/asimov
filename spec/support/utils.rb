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
end
