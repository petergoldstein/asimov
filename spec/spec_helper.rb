require "asimov"
require "securerandom"
require "vcr"

Dir[File.expand_path("spec/support/**/*.rb")].each { |f| require f }

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = "spec/fixtures/cassettes"
  c.default_cassette_options = { record: ENV["RUN_LIVE"].nil? ? :new_episodes : :all }
  c.filter_sensitive_data("<OPENAI_ACCESS_TOKEN>") { Asimov.configuration.access_token }
  c.filter_sensitive_data("<OPENAI_ORGANIZATION_ID>") { Asimov.configuration.organization_id }
end

RSpec.configure do |c|
  c.expect_with :rspec do |rspec|
    rspec.syntax = :expect
  end

  c.before do |example|
    Utils.reset_global_configuration
    Utils.load_global_configuration if example.metadata[:vcr]
  end
end

RSPEC_ROOT = File.dirname __FILE__
