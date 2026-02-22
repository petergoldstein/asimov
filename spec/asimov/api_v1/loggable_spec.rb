require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Loggable do
  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:models) { Asimov::ApiV1::Models.new(client: client) }

  let(:http_method_class) { Net::HTTP::Get }
  let(:request_double) do
    instance_double(HTTParty::Request, http_method: http_method_class,
                                       path: URI("https://api.openai.com/v1/models"))
  end
  let(:success_response) do
    instance_double(HTTParty::Response, code: 200,
                                        parsed_response: { "data" => [] },
                                        request: request_double)
  end

  describe "logging behavior" do
    context "when no logger is configured" do
      it "does not log and returns the response" do
        allow(Asimov::ApiV1::Models).to receive(:get).and_return(success_response)
        result = models.list
        expect(result).to eq({ "data" => [] })
      end
    end

    context "when a logger is configured" do
      let(:test_logger) { double("logger") } # rubocop:disable RSpec/VerifiedDoubles

      before do
        allow(test_logger).to receive(:info)
        Asimov.configure { |c| c.logger = test_logger }
      end

      it "logs the request and response" do
        allow(Asimov::ApiV1::Models).to receive(:get).and_return(success_response)
        models.list
        expect(test_logger).to have_received(:info).with(/\[Asimov\].*200/)
      end

      context "when the response has a nil http_method" do
        let(:broken_request) do
          instance_double(HTTParty::Request, http_method: nil,
                                             path: URI("https://api.openai.com/v1/models"))
        end
        let(:broken_response) do
          instance_double(HTTParty::Response, code: 200,
                                              parsed_response: { "data" => [] },
                                              request: broken_request)
        end

        it "does not raise and still returns the response" do
          allow(Asimov::ApiV1::Models).to receive(:get).and_return(broken_response)
          result = models.list
          expect(result).to eq({ "data" => [] })
        end
      end
    end
  end
end
