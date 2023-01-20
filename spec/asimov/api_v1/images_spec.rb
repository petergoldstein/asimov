require_relative "../../spec_helper"

RSpec.describe Asimov::ApiV1::Images do
  subject(:images) { described_class.new(client: client) }

  let(:api_key) { SecureRandom.hex(4) }
  let(:client) { Asimov::Client.new(api_key: api_key) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }

  it_behaves_like "sends requests to the v1 API"

  describe "#create" do
    let(:path_string) { "/images/generations" }
    let(:prompt) { SecureRandom.hex(4) }

    context "when the required prompt parameter is present" do
      let(:merged_parameters) do
        parameters.merge({ prompt: prompt })
      end

      it "calls json_post on the client with the expected arguments" do
        allow(images).to receive(:json_post).with(path: path_string,
                                                  parameters: merged_parameters).and_return(ret_val)
        expect(images.create(prompt: prompt, parameters: parameters)).to eq(ret_val)
        expect(images).to have_received(:json_post).with(path: path_string,
                                                         parameters: merged_parameters)
      end
    end

    context "when the required prompt parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          images.create(prompt: nil)
        end.to raise_error Asimov::MissingRequiredParameterError

        expect do
          images.create(prompt: nil, parameters: parameters)
        end.to raise_error Asimov::MissingRequiredParameterError
      end
    end
  end

  describe "#edit" do
    let(:path_string) { "/images/edits" }
    let(:prompt) { SecureRandom.hex(4) }
    let(:image_filename) { SecureRandom.hex(4) }

    context "when the required prompt parameter is present" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) }
      end

      context "when the required image parameter is present" do
        context "when the image file can be loaded" do
          let(:image_file) { instance_double(File) }

          before do
            allow(File).to receive(:open).with(image_filename).and_return(image_file)
          end

          after do
            expect(File).to have_received(:open).with(image_filename)
          end

          context "when the optional mask parameter is not present" do
            let(:merged_parameters) do
              parameters.merge({ image: image_file, prompt: prompt })
            end

            it "calls multipart_post on the client with the expected arguments" do
              allow(images).to receive(:multipart_post).with(path: path_string,
                                                             parameters: merged_parameters)
                                                       .and_return(ret_val)
              expect(images.create_edit(image: image_filename, prompt: prompt,
                                        parameters: parameters)).to eq(ret_val)
              expect(images).to have_received(:multipart_post).with(path: path_string,
                                                                    parameters: merged_parameters)
            end
          end

          context "when the optional mask parameter is present" do
            let(:mask_filename) { SecureRandom.hex(4) }
            let(:parameters) do
              { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), mask: mask_filename }
            end

            context "when the mask file can be loaded" do
              let(:mask_file) { instance_double(File) }
              let(:merged_parameters) do
                parameters.merge({ image: image_file, mask: mask_file, prompt: prompt })
              end

              before do
                allow(File).to receive(:open).with(mask_filename).and_return(mask_file)
              end

              after do
                expect(File).to have_received(:open).with(mask_filename)
              end

              it "calls multipart_post on the client with the expected arguments" do
                allow(images).to receive(:multipart_post).with(path: path_string,
                                                               parameters: merged_parameters)
                                                         .and_return(ret_val)
                expect(images.create_edit(image: image_filename, prompt: prompt,
                                          parameters: parameters)).to eq(ret_val)
                expect(images).to have_received(:multipart_post).with(path: path_string,
                                                                      parameters: merged_parameters)
              end
            end

            context "when the image file cannot be loaded" do
              before do
                allow(File).to receive(:open).with(mask_filename).and_raise(Errno::ENOENT)
              end

              after do
                expect(File).to have_received(:open).with(mask_filename)
              end

              it "reraises the underlying error" do
                expect do
                  images.create_edit(image: image_filename, prompt: prompt, parameters: parameters)
                end.to raise_error(Asimov::FileCannotBeOpenedError)
              end
            end
          end
        end

        context "when the image file cannot be loaded" do
          before do
            allow(File).to receive(:open).with(image_filename).and_raise(Errno::ENOENT)
          end

          after do
            expect(File).to have_received(:open).with(image_filename)
          end

          it "reraises the underlying error" do
            expect do
              images.create_edit(image: image_filename, prompt: prompt, parameters: parameters)
            end.to raise_error(Asimov::FileCannotBeOpenedError)
          end
        end
      end

      context "when the required image parameter is missing" do
        it "raises a MissingRequiredParameterError" do
          expect do
            images.create_edit(image: nil, prompt: prompt, parameters: parameters)
          end.to raise_error(Asimov::MissingRequiredParameterError)
        end
      end
    end

    context "when the required prompt parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          images.create_edit(image: image_filename, prompt: nil, parameters: parameters)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end

  describe "#create_variation" do
    let(:path_string) { "/images/variations" }

    context "when the required image parameter is present" do
      let(:image_filename) { SecureRandom.hex(4) }
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          image: image_filename }
      end

      context "when the image file can be loaded" do
        let(:image_file) { instance_double(File) }

        before do
          allow(File).to receive(:open).with(image_filename).and_return(image_file)
        end

        after do
          expect(File).to have_received(:open).with(image_filename)
        end

        context "when the optional mask parameter is not present" do
          let(:merged_parameters) do
            parameters.merge({ image: image_file })
          end

          it "calls multipart_post on the client with the expected arguments" do
            allow(images).to receive(:multipart_post).with(path: path_string,
                                                           parameters: merged_parameters)
                                                     .and_return(ret_val)
            expect(images.create_variation(image: image_filename,
                                           parameters: parameters)).to eq(ret_val)
            expect(images).to have_received(:multipart_post).with(path: path_string,
                                                                  parameters: merged_parameters)
          end
        end

        context "when the optional mask parameter is present" do
          let(:mask_filename) { SecureRandom.hex(4) }
          let(:parameters) do
            { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
              mask: mask_filename }
          end

          context "when the mask file can be loaded" do
            let(:mask_file) { instance_double(File) }
            let(:merged_parameters) do
              parameters.merge({ image: image_file, mask: mask_file })
            end

            before do
              allow(File).to receive(:open).with(mask_filename).and_return(mask_file)
            end

            after do
              expect(File).to have_received(:open).with(mask_filename)
            end

            it "calls multipart_post on the client with the expected arguments" do
              allow(images).to receive(:multipart_post).with(path: path_string,
                                                             parameters: merged_parameters)
                                                       .and_return(ret_val)
              expect(images.create_variation(image: image_filename,
                                             parameters: parameters)).to eq(ret_val)
              expect(images).to have_received(:multipart_post).with(path: path_string,
                                                                    parameters: merged_parameters)
            end
          end

          context "when the image file cannot be loaded" do
            before do
              allow(File).to receive(:open).with(mask_filename).and_raise(Errno::ENOENT)
            end

            after do
              expect(File).to have_received(:open).with(mask_filename)
            end

            it "reraises the underlying error" do
              expect do
                images.create_variation(image: image_filename, parameters: parameters)
              end.to raise_error(Asimov::FileCannotBeOpenedError)
            end
          end
        end
      end

      context "when the image file cannot be loaded" do
        before do
          allow(File).to receive(:open).with(image_filename).and_raise(Errno::ENOENT)
        end

        after do
          expect(File).to have_received(:open).with(image_filename)
        end

        it "reraises the underlying error" do
          expect do
            images.create_variation(image: image_filename, parameters: parameters)
          end.to raise_error(Asimov::FileCannotBeOpenedError)
        end
      end
    end

    context "when the required image parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          images.create_variation(image: nil)
        end.to raise_error(Asimov::MissingRequiredParameterError)

        expect do
          images.create_variation(image: nil, parameters: parameters)
        end.to raise_error(Asimov::MissingRequiredParameterError)
      end
    end
  end
end
