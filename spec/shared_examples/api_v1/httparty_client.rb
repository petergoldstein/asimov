shared_examples_for "sends requests to the v1 API" do
  subject(:instance) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:headers) { client.headers }
  let(:resource) { SecureRandom.hex(4) }
  let(:id) { SecureRandom.hex(4) }
  let(:full_path) { "#{client.openai_api_base}#{path}" }
  let(:parsed_body) { { SecureRandom.hex(4) => SecureRandom.hex(4) } }
  let(:ret_val) do
    resp = instance_double(HTTParty::Response)
    allow(resp).to receive_messages(code: 200, parsed_response: parsed_body)
    resp
  end

  describe "full_path" do
    let(:path) { "/#{SecureRandom.hex(4)}/#{SecureRandom.hex(4)}" }

    it "does not equal the path and starts with the https:// prefix" do
      expect(full_path).not_to eq(path)
      expect(full_path).to start_with("https://")
    end
  end

  describe "#rest_index" do
    let(:resource) { SecureRandom.hex(4) }
    let(:path) { "/#{resource}" }

    context "when there are no request options" do
      context "when the underlying HTTP call does not return an error" do
        before do
          allow(described_class).to receive(:get).with(full_path,
                                                       { headers: headers }).and_return(ret_val)
        end

        after do
          expect(described_class).to have_received(:get).with(full_path, { headers: headers })
        end

        it "passes the path and headers to the get method of HTTParty" do
          expect(instance.rest_index(resource: resource)).to eq(parsed_body)
        end
      end

      context "when there is an error in the HTTP stack" do
        context "when the underlying HTTP call raises a Net::OpenTimeout" do
          before do
            allow(described_class).to receive(:get).with(full_path,
                                                         { headers: headers })
                                                   .and_raise(Net::OpenTimeout)
          end

          after do
            expect(described_class).to have_received(:get).with(full_path, { headers: headers })
          end

          it "raises an Asimov::OpenTimeout" do
            expect do
              instance.rest_index(resource: resource)
            end.to raise_error(Asimov::OpenTimeout)
          end
        end

        context "when the underlying HTTP call raises a Net::ReadTimeout" do
          before do
            allow(described_class).to receive(:get).with(full_path,
                                                         { headers: headers })
                                                   .and_raise(Net::ReadTimeout)
          end

          after do
            expect(described_class).to have_received(:get).with(full_path, { headers: headers })
          end

          it "raises an Asimov::OpenTimeout" do
            expect do
              instance.rest_index(resource: resource)
            end.to raise_error(Asimov::ReadTimeout)
          end
        end

        [Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
         Net::HTTPHeaderSyntaxError, Net::ProtocolError].each do |e|
          context "when the underlying HTTP call raises a #{e.name}" do
            before do
              allow(described_class).to receive(:get).with(full_path,
                                                           { headers: headers })
                                                     .and_raise(e)
            end

            after do
              expect(described_class).to have_received(:get).with(full_path, { headers: headers })
            end

            it "raises an Asimov::NetworkError" do
              expect do
                instance.rest_index(resource: resource)
              end.to raise_error(Asimov::NetworkError)
            end
          end
        end
      end
    end

    context "when request options are passed to the client" do
      let(:request_options) { { read_timeout: 1234 } }
      let(:client) { Asimov::Client.new(api_key: api_key, request_options: request_options) }

      before do
        allow(described_class).to receive(:get).with(full_path,
                                                     { headers: headers }.merge(request_options))
                                               .and_return(ret_val)
      end

      after do
        expect(described_class).to have_received(:get)
          .with(full_path,
                { headers: headers }.merge(request_options))
      end

      it "passes the path, headers, and request options to the get method of HTTParty" do
        expect(instance.rest_index(resource: resource)).to eq(parsed_body)
      end
    end
  end

  describe "#rest_delete" do
    let(:path) { "/#{resource}/#{id}" }

    context "when there are no request options" do
      context "when the underlying HTTP call does not return an error" do
        before do
          allow(described_class).to receive(:delete).with(full_path,
                                                          { headers: headers }).and_return(ret_val)
        end

        after do
          expect(described_class).to have_received(:delete).with(full_path, { headers: headers })
        end

        it "passes the path and headers to the delete method of HTTParty" do
          expect(instance.rest_delete(resource: resource, id: id)).to eq(parsed_body)
        end
      end

      context "when there is an error in the HTTP stack" do
        context "when the underlying HTTP call raises a Net::OpenTimeout" do
          before do
            allow(described_class).to receive(:delete).with(full_path,
                                                            { headers: headers })
                                                      .and_raise(Net::OpenTimeout)
          end

          after do
            expect(described_class).to have_received(:delete).with(full_path, { headers: headers })
          end

          it "raises an Asimov::OpenTimeout" do
            expect do
              instance.rest_delete(resource: resource, id: id)
            end.to raise_error(Asimov::OpenTimeout)
          end
        end

        context "when the underlying HTTP call raises a Net::ReadTimeout" do
          before do
            allow(described_class).to receive(:delete).with(full_path,
                                                            { headers: headers })
                                                      .and_raise(Net::ReadTimeout)
          end

          after do
            expect(described_class).to have_received(:delete).with(full_path, { headers: headers })
          end

          it "raises an Asimov::ReadTimeout" do
            expect do
              instance.rest_delete(resource: resource, id: id)
            end.to raise_error(Asimov::ReadTimeout)
          end
        end

        context "when the underlying HTTP call raises a Timeout::Error" do
          before do
            allow(described_class).to receive(:delete).with(full_path,
                                                            { headers: headers })
                                                      .and_raise(Timeout::Error)
          end

          after do
            expect(described_class).to have_received(:delete).with(full_path, { headers: headers })
          end

          it "raises an Asimov::ReadTimeout" do
            expect do
              instance.rest_delete(resource: resource, id: id)
            end.to raise_error(Asimov::TimeoutError)
          end
        end

        [Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
         Net::HTTPHeaderSyntaxError, Net::ProtocolError].each do |e|
          context "when the underlying HTTP call raises a #{e.name}" do
            before do
              allow(described_class).to receive(:delete).with(full_path,
                                                              { headers: headers })
                                                        .and_raise(e)
            end

            after do
              expect(described_class).to have_received(:delete).with(full_path,
                                                                     { headers: headers })
            end

            it "raises an Asimov::NetworkError" do
              expect do
                instance.rest_delete(resource: resource, id: id)
              end.to raise_error(Asimov::NetworkError)
            end
          end
        end
      end
    end

    context "when request options are passed to the client" do
      let(:request_options) { { read_timeout: 1234 } }
      let(:client) { Asimov::Client.new(api_key: api_key, request_options: request_options) }

      before do
        allow(described_class).to receive(:delete).with(full_path,
                                                        { headers: headers }.merge(request_options))
                                                  .and_return(ret_val)
      end

      after do
        expect(described_class).to have_received(:delete)
          .with(full_path,
                { headers: headers }.merge(request_options))
      end

      it "passes the path, headers, and request options to the get method of HTTParty" do
        expect(instance.rest_delete(resource: resource, id: id)).to eq(parsed_body)
      end
    end
  end

  describe "#rest_get" do
    let(:path) { "/#{resource}/#{id}" }

    context "when there are no request options" do
      context "when the underlying HTTP call does not return an error" do
        before do
          allow(described_class).to receive(:get).with(full_path,
                                                       { headers: headers }).and_return(ret_val)
        end

        after do
          expect(described_class).to have_received(:get).with(full_path, { headers: headers })
        end

        it "passes the path and headers to the get method of HTTParty" do
          expect(instance.rest_get(resource: resource, id: id)).to eq(parsed_body)
        end
      end

      context "when there is an error in the HTTP stack" do
        context "when the underlying HTTP call raises a Net::OpenTimeout" do
          before do
            allow(described_class).to receive(:get).with(full_path,
                                                         { headers: headers })
                                                   .and_raise(Net::OpenTimeout)
          end

          after do
            expect(described_class).to have_received(:get).with(full_path, { headers: headers })
          end

          it "raises an Asimov::OpenTimeout" do
            expect do
              instance.rest_get(resource: resource, id: id)
            end.to raise_error(Asimov::OpenTimeout)
          end
        end

        context "when the underlying HTTP call raises a Net::ReadTimeout" do
          before do
            allow(described_class).to receive(:get).with(full_path,
                                                         { headers: headers })
                                                   .and_raise(Net::ReadTimeout)
          end

          after do
            expect(described_class).to have_received(:get).with(full_path, { headers: headers })
          end

          it "raises an Asimov::OpenTimeout" do
            expect do
              instance.rest_get(resource: resource, id: id)
            end.to raise_error(Asimov::ReadTimeout)
          end
        end

        [Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
         Net::HTTPHeaderSyntaxError, Net::ProtocolError].each do |e|
          context "when the underlying HTTP call raises a #{e.name}" do
            before do
              allow(described_class).to receive(:get).with(full_path,
                                                           { headers: headers })
                                                     .and_raise(e)
            end

            after do
              expect(described_class).to have_received(:get).with(full_path, { headers: headers })
            end

            it "raises an Asimov::NetworkError" do
              expect do
                instance.rest_get(resource: resource, id: id)
              end.to raise_error(Asimov::NetworkError)
            end
          end
        end
      end
    end

    context "when request options are passed to the client" do
      let(:request_options) { { read_timeout: 1234 } }
      let(:client) { Asimov::Client.new(api_key: api_key, request_options: request_options) }

      before do
        allow(described_class).to receive(:get).with(full_path,
                                                     { headers: headers }.merge(request_options))
                                               .and_return(ret_val)
      end

      after do
        expect(described_class).to have_received(:get)
          .with(full_path,
                { headers: headers }.merge(request_options))
      end

      it "passes the path, headers, and request options to the get method of HTTParty" do
        expect(instance.rest_get(resource: resource, id: id)).to eq(parsed_body)
      end
    end
  end

  describe "#rest_create_w_json_params" do
    let(:path) { "/#{resource}" }

    context "when there are no request options" do
      context "when the underlying HTTP call does not return an error" do
        before do
          allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                     body: body })
                                                  .and_return(ret_val)
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
            expect(instance.rest_create_w_json_params(resource: resource,
                                                      parameters: parameters)).to eq(parsed_body)
          end
        end

        context "when parameters is nil" do
          let(:body) { nil }

          it "passes the path, headers (with correct content type) and nil to the post method of " \
             "HTTParty" do
            expect(instance.rest_create_w_json_params(resource: resource,
                                                      parameters: nil)).to eq(parsed_body)
          end
        end
      end

      context "when there is an error in the underlying HTTP stack" do
        context "when the underlying HTTP call raises a Net::OpenTimeout" do
          before do
            allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                       body: body })
                                                    .and_raise(Net::OpenTimeout)
          end

          after do
            expect(described_class).to have_received(:post).with(full_path,
                                                                 { headers: headers, body: body })
          end

          context "when parameters is not nil" do
            let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
            let(:body) { parameters.to_json }

            it "passes the path, headers (with correct content type) and JSON-ified parameters " \
               "to the post method of HTTParty and raises an Asimov::OpenTimeout" do
              expect do
                instance.rest_create_w_json_params(resource: resource, parameters: parameters)
              end.to raise_error(Asimov::OpenTimeout)
            end
          end

          context "when parameters is nil" do
            let(:body) { nil }

            it "passes the path, headers (with correct content type) and nil to the post method " \
               "of HTTParty and raises an Asimov::OpenTimeout" do
              expect do
                instance.rest_create_w_json_params(resource: resource, parameters: nil)
              end.to raise_error(Asimov::OpenTimeout)
            end
          end
        end

        context "when the underlying HTTP call raises a Net::ReadTimeout" do
          before do
            allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                       body: body })
                                                    .and_raise(Net::ReadTimeout)
          end

          after do
            expect(described_class).to have_received(:post).with(full_path,
                                                                 { headers: headers, body: body })
          end

          context "when parameters is not nil" do
            let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
            let(:body) { parameters.to_json }

            it "passes the path, headers (with correct content type) and JSON-ified parameters " \
               "to the post method of HTTParty and raises an Asimov::ReadTimeout" do
              expect do
                instance.rest_create_w_json_params(resource: resource, parameters: parameters)
              end.to raise_error(Asimov::ReadTimeout)
            end
          end

          context "when parameters is nil" do
            let(:body) { nil }

            it "passes the path, headers (with correct content type) and nil to the post method " \
               "of HTTParty and raises an Asimov::ReadTimeout" do
              expect do
                instance.rest_create_w_json_params(resource: resource, parameters: nil)
              end.to raise_error(Asimov::ReadTimeout)
            end
          end
        end

        context "when the underlying HTTP call raises a Net::WriteTimeout" do
          before do
            allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                       body: body })
                                                    .and_raise(Net::WriteTimeout)
          end

          after do
            expect(described_class).to have_received(:post).with(full_path,
                                                                 { headers: headers, body: body })
          end

          context "when parameters is not nil" do
            let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
            let(:body) { parameters.to_json }

            it "passes the path, headers (with correct content type) and JSON-ified parameters " \
               "to the post method of HTTParty and raises an Asimov::WriteTimeout" do
              expect do
                instance.rest_create_w_json_params(resource: resource, parameters: parameters)
              end.to raise_error(Asimov::WriteTimeout)
            end
          end

          context "when parameters is nil" do
            let(:body) { nil }

            it "passes the path, headers (with correct content type) and nil to the post method " \
               "of HTTParty and raises an Asimov::WriteTimeout" do
              expect do
                instance.rest_create_w_json_params(resource: resource, parameters: nil)
              end.to raise_error(Asimov::WriteTimeout)
            end
          end
        end

        [Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
         Net::HTTPHeaderSyntaxError, Net::ProtocolError].each do |e|
          context "when the underlying HTTP call raises a #{e.name}" do
            before do
              allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                         body: body }).and_raise(e)
            end

            after do
              expect(described_class).to have_received(:post).with(full_path,
                                                                   { headers: headers, body: body })
            end

            context "when parameters is not nil" do
              let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
              let(:body) { parameters.to_json }

              it "passes the path, headers (with correct content type) and JSON-ified parameters " \
                 "to the post method of HTTParty and raises an Asimov::NetworkError" do
                expect do
                  instance.rest_create_w_json_params(resource: resource, parameters: parameters)
                end.to raise_error(Asimov::NetworkError)
              end
            end

            context "when parameters is nil" do
              let(:body) { nil }

              it "passes the path, headers (with correct content type) and nil to the post " \
                 "method of HTTParty and raises an Asimov::NetworkError" do
                expect do
                  instance.rest_create_w_json_params(resource: resource, parameters: nil)
                end.to raise_error(Asimov::NetworkError)
              end
            end
          end
        end
      end
    end

    context "when request options are passed to the client" do
      let(:request_options) { { read_timeout: 1234 } }
      let(:client) { Asimov::Client.new(api_key: api_key, request_options: request_options) }

      before do
        allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                   body: body }
                                                                   .merge(request_options))
                                                .and_return(ret_val)
      end

      after do
        expect(described_class).to have_received(:post).with(full_path,
                                                             { headers: headers, body: body }
                                                             .merge(request_options))
      end

      context "when parameters is not nil" do
        let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
        let(:body) { parameters.to_json }

        it "passes the path, headers (with correct content type), JSON-ified parameters, " \
           "and request options the post method of HTTParty" do
          expect(instance.rest_create_w_json_params(resource: resource,
                                                    parameters: parameters)).to eq(parsed_body)
        end
      end
    end
  end

  describe "#rest_create_w_multipart_params" do
    let(:headers) { client.headers("multipart/form-data") }
    let(:path) { "/#{resource}" }

    context "when there are no request options" do
      context "when the underlying HTTP call does not return an error" do
        before do
          allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                     body: body })
                                                  .and_return(ret_val)
        end

        after do
          expect(described_class).to have_received(:post).with(full_path,
                                                               { headers: headers, body: body })
        end

        context "with an explicit parameters argument" do
          let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
          let(:body) { parameters }

          it "passes the path, headers (with correct content type), and unaltered parameters " \
             "to the post method of HTTParty" do
            expect(instance.rest_create_w_multipart_params(resource: resource,
                                                           parameters: parameters))
              .to eq(parsed_body)
          end
        end

        context "with no explicit parameters argument" do
          let(:body) { nil }

          it "passes the path, headers (with correct content type), and nil to the post " \
             "method of HTTParty" do
            expect(instance.rest_create_w_multipart_params(resource: resource)).to eq(parsed_body)
          end
        end
      end

      context "when there is an error in the underlying HTTP stack" do
        context "when the underlying HTTP call raises a Net::OpenTimeout" do
          before do
            allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                       body: body })
                                                    .and_raise(Net::OpenTimeout)
          end

          after do
            expect(described_class).to have_received(:post).with(full_path,
                                                                 { headers: headers, body: body })
          end

          context "with an explicit parameters argument" do
            let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
            let(:body) { parameters }

            it "passes the path, headers (with correct content type), and unaltered parameters " \
               "to the post method of HTTParty" do
              expect do
                instance.rest_create_w_multipart_params(resource: resource, parameters: parameters)
              end.to raise_error(Asimov::OpenTimeout)
            end
          end

          context "with no explicit parameters argument" do
            let(:body) { nil }

            it "passes the path, headers (with correct content type), and nil to the post " \
               "method of HTTParty" do
              expect do
                instance.rest_create_w_multipart_params(resource: resource)
              end.to raise_error(Asimov::OpenTimeout)
            end
          end
        end

        context "when the underlying HTTP call raises a Net::ReadTimeout" do
          before do
            allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                       body: body })
                                                    .and_raise(Net::ReadTimeout)
          end

          after do
            expect(described_class).to have_received(:post).with(full_path,
                                                                 { headers: headers, body: body })
          end

          context "with an explicit parameters argument" do
            let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
            let(:body) { parameters }

            it "passes the path, headers (with correct content type), and unaltered parameters " \
               "to the post method of HTTParty" do
              expect do
                instance.rest_create_w_multipart_params(resource: resource, parameters: parameters)
              end.to raise_error(Asimov::ReadTimeout)
            end
          end

          context "with no explicit parameters argument" do
            let(:body) { nil }

            it "passes the path, headers (with correct content type), and nil to the post " \
               "method of HTTParty" do
              expect do
                instance.rest_create_w_multipart_params(resource: resource)
              end.to raise_error(Asimov::ReadTimeout)
            end
          end
        end

        context "when the underlying HTTP call raises a Net::WriteTimeout" do
          before do
            allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                       body: body })
                                                    .and_raise(Net::WriteTimeout)
          end

          after do
            expect(described_class).to have_received(:post).with(full_path,
                                                                 { headers: headers, body: body })
          end

          context "with an explicit parameters argument" do
            let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
            let(:body) { parameters }

            it "passes the path, headers (with correct content type), and unaltered parameters " \
               "to the post method of HTTParty" do
              expect do
                instance.rest_create_w_multipart_params(resource: resource, parameters: parameters)
              end.to raise_error(Asimov::WriteTimeout)
            end
          end

          context "with no explicit parameters argument" do
            let(:body) { nil }

            it "passes the path, headers (with correct content type), and nil to the post " \
               "method of HTTParty" do
              expect do
                instance.rest_create_w_multipart_params(resource: resource)
              end.to raise_error(Asimov::WriteTimeout)
            end
          end
        end

        [Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
         Net::HTTPHeaderSyntaxError, Net::ProtocolError].each do |e|
          context "when the underlying HTTP call raises a #{e.name}" do
            before do
              allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                         body: body }).and_raise(e)
            end

            after do
              expect(described_class).to have_received(:post).with(full_path,
                                                                   { headers: headers, body: body })
            end

            context "with an explicit parameters argument" do
              let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
              let(:body) { parameters }

              it "passes the path, headers (with correct content type), and unaltered parameters " \
                 "to the post method of HTTParty" do
                expect do
                  instance.rest_create_w_multipart_params(resource: resource,
                                                          parameters: parameters)
                end.to raise_error(Asimov::NetworkError)
              end
            end

            context "with no explicit parameters argument" do
              let(:body) { nil }

              it "passes the path, headers (with correct content type), and nil to the post " \
                 "method of HTTParty" do
                expect do
                  instance.rest_create_w_multipart_params(resource: resource)
                end.to raise_error(Asimov::NetworkError)
              end
            end
          end
        end
      end
    end

    context "when request options are passed to the client" do
      let(:request_options) { { read_timeout: 1234 } }
      let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
      let(:body) { parameters }
      let(:client) { Asimov::Client.new(api_key: api_key, request_options: request_options) }

      before do
        allow(described_class).to receive(:post).with(full_path, { headers: headers,
                                                                   body: body }
                                                                   .merge(request_options))
                                                .and_return(ret_val)
      end

      after do
        expect(described_class).to have_received(:post).with(full_path,
                                                             { headers: headers, body: body }
                                                             .merge(request_options))
      end

      it "passes the path, headers (with correct content type), and unaltered parameters " \
         "to the post method of HTTParty" do
        expect(instance.rest_create_w_multipart_params(resource: resource,
                                                       parameters: parameters)).to eq(parsed_body)
      end
    end
  end

  describe "#rest_get_streamed_download" do
    let(:fragment) do
      f = instance_double(HTTParty::ResponseFragment)
      allow(f).to receive(:code).and_return(code)
      f
    end
    let(:ext) { "content" }
    let(:path) { "/#{resource}/#{id}/#{ext}" }
    let(:resource_args) { [resource, id, ext] }

    let(:writer) { instance_double(File) }

    context "when there are no request options" do
      context "when the underlying HTTP call does not return an error" do
        let(:code) { 200 }

        before do
          allow(described_class).to receive(:get).with(full_path, { headers: headers,
                                                                    stream_body: true })
                                                 .and_yield(fragment)
          allow(writer).to receive(:write).with(fragment)
        end

        after do
          expect(described_class).to have_received(:get).with(full_path,
                                                              { headers: headers,
                                                                stream_body: true })
          expect(writer).to have_received(:write).with(fragment)
        end

        it "passes the path to the stream download get method of HTTParty" do
          expect do
            instance.rest_get_streamed_download(resource: resource_args, writer: writer)
          end.not_to raise_error
        end
      end

      context "when the underlying HTTP call has an error code" do
        let(:code) { 500 }

        before do
          allow(described_class).to receive(:get).with(full_path, { headers: headers,
                                                                    stream_body: true })
                                                 .and_yield(fragment)
          allow(writer).to receive(:write).with(fragment)
        end

        after do
          expect(described_class).to have_received(:get).with(full_path,
                                                              { headers: headers,
                                                                stream_body: true })
          expect(writer).not_to have_received(:write).with(fragment)
        end

        it "passes the path to the stream download get method of HTTParty" do
          expect do
            instance.rest_get_streamed_download(resource: resource_args, writer: writer)
          end.to raise_error(Asimov::RequestError)
        end
      end
    end

    context "when request options are passed to the client" do
      context "when the underlying HTTP call does not return an error" do
        let(:code) { 200 }
        let(:request_options) { { read_timeout: 1234 } }
        let(:client) { Asimov::Client.new(api_key: api_key, request_options: request_options) }

        before do
          allow(described_class).to receive(:get).with(full_path, { headers: headers,
                                                                    stream_body: true }
                                                                    .merge(request_options))
                                                 .and_yield(fragment)
          allow(writer).to receive(:write).with(fragment)
        end

        after do
          expect(described_class).to have_received(:get).with(full_path,
                                                              { headers: headers,
                                                                stream_body: true }
                                                                .merge(request_options))
          expect(writer).to have_received(:write).with(fragment)
        end

        it "passes the path to the stream download get method of HTTParty" do
          expect do
            instance.rest_get_streamed_download(resource: resource_args, writer: writer)
          end.not_to raise_error
        end
      end

      context "when the underlying HTTP call raises a Net::OpenTimeout" do
        let(:code) { 200 }
        let(:request_options) { { read_timeout: 1234 } }
        let(:client) { Asimov::Client.new(api_key: api_key, request_options: request_options) }

        before do
          allow(described_class).to receive(:get).with(full_path, { headers: headers,
                                                                    stream_body: true }
                                                                    .merge(request_options))
                                                 .and_raise(Net::OpenTimeout)
          allow(writer).to receive(:write).with(fragment)
        end

        after do
          expect(described_class).to have_received(:get).with(full_path,
                                                              { headers: headers,
                                                                stream_body: true }
                                                                .merge(request_options))
          expect(writer).not_to have_received(:write).with(fragment)
        end

        it "passes the path to the stream download get method of HTTParty" do
          expect do
            instance.rest_get_streamed_download(resource: resource_args, writer: writer)
          end.to raise_error(Asimov::OpenTimeout)
        end
      end

      context "when the underlying HTTP call raises a Net::ReadTimeout" do
        let(:code) { 200 }
        let(:request_options) { { read_timeout: 1234 } }
        let(:client) { Asimov::Client.new(api_key: api_key, request_options: request_options) }

        before do
          allow(described_class).to receive(:get).with(full_path, { headers: headers,
                                                                    stream_body: true }
                                                                    .merge(request_options))
                                                 .and_raise(Net::ReadTimeout)
          allow(writer).to receive(:write).with(fragment)
        end

        after do
          expect(described_class).to have_received(:get).with(full_path,
                                                              { headers: headers,
                                                                stream_body: true }
                                                                .merge(request_options))
          expect(writer).not_to have_received(:write).with(fragment)
        end

        it "passes the path to the stream download get method of HTTParty" do
          expect do
            instance.rest_get_streamed_download(resource: resource_args, writer: writer)
          end.to raise_error(Asimov::ReadTimeout)
        end
      end

      [Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
       Net::HTTPHeaderSyntaxError, Net::ProtocolError].each do |e|
        context "when the underlying HTTP call raises a #{e.name}" do
          let(:code) { 200 }
          let(:request_options) { { read_timeout: 1234 } }
          let(:client) { Asimov::Client.new(api_key: api_key, request_options: request_options) }

          before do
            allow(described_class).to receive(:get).with(full_path, { headers: headers,
                                                                      stream_body: true }
                                                                      .merge(request_options))
                                                   .and_raise(e)
            allow(writer).to receive(:write).with(fragment)
          end

          after do
            expect(described_class).to have_received(:get).with(full_path,
                                                                { headers: headers,
                                                                  stream_body: true }
                                                                  .merge(request_options))
            expect(writer).not_to have_received(:write).with(fragment)
          end

          it "passes the path to the stream download get method of HTTParty" do
            expect do
              instance.rest_get_streamed_download(resource: resource_args, writer: writer)
            end.to raise_error(Asimov::NetworkError)
          end
        end
      end
    end
  end
end
