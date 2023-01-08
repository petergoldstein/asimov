shared_examples_for "sends requests to the v1 API" do
  subject(:instance) { described_class.new(client: client) }

  let(:access_token) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(access_token: access_token) }
  let(:headers) { client.headers }
  let(:path) { "/#{SecureRandom.hex(4)}/#{SecureRandom.hex(4)}" }
  let(:full_path) { path }
  let(:parsed_body) { { SecureRandom.hex(4) => SecureRandom.hex(4) } }
  let(:ret_val) do
    resp = instance_double(HTTParty::Response)
    allow(resp).to receive(:parsed_response).and_return(parsed_body)
    resp
  end

  describe "#http_delete" do
    before do
      allow(described_class).to receive(:delete).with(full_path,
                                                      { headers: headers }).and_return(ret_val)
    end

    after do
      expect(described_class).to have_received(:delete).with(full_path, { headers: headers })
    end

    it "passes the path and headers to the delete method of HTTParty" do
      expect(instance.http_delete(path: path)).to eq(parsed_body)
    end
  end

  describe "#http_get" do
    before do
      allow(described_class).to receive(:get).with(full_path,
                                                   { headers: headers }).and_return(ret_val)
    end

    after do
      expect(described_class).to have_received(:get).with(full_path, { headers: headers })
    end

    it "passes the path and headers to the get method of HTTParty" do
      expect(instance.http_get(path: path)).to eq(parsed_body)
    end
  end

  describe "#json_post" do
    before do
      allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                 body: body }).and_return(ret_val)
    end

    after do
      expect(described_class).to have_received(:post).with(full_path,
                                                           { headers: headers, body: body })
    end

    context "when parameters is not nil" do
      let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
      let(:body) { parameters.to_json }

      it "passes the path, headers (with correct content type) and JSON-ified parameters to " \
         "the post method of HTTParty" do
        expect(instance.json_post(path: path, parameters: parameters)).to eq(parsed_body)
      end
    end

    context "when parameters is nil" do
      let(:body) { nil }

      it "passes the path, headers (with correct content type) and nil to the post method of " \
         "HTTParty" do
        expect(instance.json_post(path: path, parameters: nil)).to eq(parsed_body)
      end
    end
  end

  describe "#multipart_post" do
    let(:headers) { client.headers("multipart/form-data") }

    before do
      allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                 body: body }).and_return(ret_val)
    end

    after do
      expect(described_class).to have_received(:post).with(full_path,
                                                           { headers: headers, body: body })
    end

    context "with an explicit parameters argument" do
      let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
      let(:body) { parameters }

      it "passes the path, headers (with correct content type), and unaltered parameters to " \
         "the post method of HTTParty" do
        expect(instance.multipart_post(path: path, parameters: parameters)).to eq(parsed_body)
      end
    end

    context "with no explicit parameters argument" do
      let(:body) { nil }

      it "passes the path, headers (with correct content type), and nil to the post " \
         "method of HTTParty" do
        expect(instance.multipart_post(path: path)).to eq(parsed_body)
      end
    end
  end
end
