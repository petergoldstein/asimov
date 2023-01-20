require_relative "../spec_helper"

RSpec.describe "Images API", type: :feature do
  let(:prompt) { "an android detective in a futuristic underground city, as digital art" }
  let(:size) { "256x256" }
  let(:client) { Asimov::Client.new }

  describe "create an image with valid parameters", :vcr do
    let(:response) do
      client.images.create(
        prompt: prompt,
        parameters: {
          size: size
        }
      )
    end
    let(:cassette) { "images create #{prompt}" }

    it "succeeds" do
      VCR.use_cassette(cassette) do
        expect(response.dig("data", 0, "url")).to include("dalle")
      end
    end
  end

  describe "create an image with too large a value for n", :vcr do
    it "raises the expected error" do
      VCR.use_cassette("images create with too large an n", preserve_exact_body_bytes: true) do
        expect do
          client.images.create(
            prompt: prompt,
            parameters: {
              size: size,
              n: 100
            }
          )
        end.to raise_error(Asimov::InvalidParameterValueError)
      end
    end
  end

  describe "create an image with too small a value for n", :vcr do
    it "raises the expected error" do
      VCR.use_cassette("images create with too small an n", preserve_exact_body_bytes: true) do
        expect do
          client.images.create(
            prompt: prompt,
            parameters: {
              size: size,
              n: 0
            }
          )
        end.to raise_error(Asimov::InvalidParameterValueError)
      end
    end
  end

  describe "create an image edit with valid parameters", :vcr do
    let(:cassette) { "images edit #{prompt}" }
    let(:prompt) { "A solid red Ruby on a blue background" }
    let(:image_filename) { Utils.fixture_filename(filename: "image.png") }
    let(:mask_filename) { Utils.fixture_filename(filename: "mask.png") }
    let(:size) { "256x256" }

    it "succeeds" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        response = client.images.create_edit(
          image: image_filename,
          prompt: prompt,
          parameters: {
            mask: mask_filename,
            size: size
          }
        )

        expect(response.dig("data", 0, "url")).to include("dalle")
      end
    end
  end

  describe "create an image edit with an extra unsupported parameter", :vcr do
    let(:cassette) { "images edit with an unsupported parameter" }
    let(:prompt) { "A solid red Ruby on a blue background" }
    let(:image_filename) { Utils.fixture_filename(filename: "image.png") }
    let(:mask_filename) { Utils.fixture_filename(filename: "mask.png") }
    let(:size) { "256x256" }

    it "raises the expected error" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        expect do
          client.images.create_edit(
            image: image_filename,
            prompt: prompt,
            parameters: {
              mask: mask_filename,
              size: size,
              notaparameter: "notavalue"
            }
          )
        end.to raise_error(Asimov::UnsupportedParameterError)
      end
    end
  end

  describe "create an image edit with an invalid value for a parameter", :vcr do
    let(:cassette) { "images edit with an invalid value for a parameter" }
    let(:prompt) { "A solid red Ruby on a blue background" }
    let(:image_filename) { Utils.fixture_filename(filename: "image.png") }
    let(:mask_filename) { Utils.fixture_filename(filename: "mask.png") }
    let(:size) { "1280x768" }

    it "raises the expected error" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        expect do
          client.images.create_edit(
            image: image_filename,
            prompt: prompt,
            parameters: {
              mask: mask_filename,
              size: size
            }
          )
        end.to raise_error(Asimov::InvalidParameterValueError)
      end
    end
  end

  describe "#create_variation", :vcr do
    let(:response) do
      client.images.create_variation(
        image: image_filename,
        parameters: {
          n: 2,
          size: size
        }
      )
    end
    let(:cassette) { "images create variation" }
    let(:image_filename) { Utils.fixture_filename(filename: "image.png") }
    let(:size) { "256x256" }

    it "succeeds" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        expect(response.dig("data", 0, "url")).to include("dalle")
      end
    end
  end
end
