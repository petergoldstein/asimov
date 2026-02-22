require "webmock/rspec"

RSpec.configure do |config|
  config.include WebMock::API, type: :integration
  config.include WebMock::Matchers, type: :integration

  config.around(:each, type: :integration) do |example|
    VCR.turned_off { example.run }
  end
end
