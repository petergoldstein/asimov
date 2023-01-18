require_relative "../spec_helper"

RSpec.describe "Images API", type: :feature do
  describe "create an image with valid parameters", :vcr do
    let(:response) do
      Asimov::Client.new.images.create(
        parameters: {
          prompt: prompt,
          size: size
        }
      )
    end
    let(:cassette) { "images generate #{prompt}" }
    let(:prompt) { "A baby sea otter cooking pasta wearing a hat of some sort" }
    let(:size) { "256x256" }

    it "succeeds" do
      VCR.use_cassette(cassette) do
        expect(response.dig("data", 0, "url")).to include("dalle")
      end
    end
  end

  describe "create an image with too large a value for n", :vcr do
    let(:cassette) { "images create with too large an n" }
    let(:prompt) { "A baby sea otter cooking pasta wearing a hat of some sort" }
    let(:size) { "256x256" }

    it "raises the expected error" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        expect do
          Asimov::Client.new.images.create(
            parameters: {
              prompt: prompt,
              size: size,
              n: 100
            }
          )
        end.to raise_error(Asimov::InvalidParameterValueError)
      end
    end
  end

  describe "create an image with too small a value for n", :vcr do
    let(:cassette) { "images create with too small an n" }
    let(:prompt) { "A baby sea otter cooking pasta wearing a hat of some sort" }
    let(:size) { "256x256" }

    it "raises the expected error" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        expect do
          Asimov::Client.new.images.create(
            parameters: {
              prompt: prompt,
              size: size,
              n: 0
            }
          )
        end.to raise_error(Asimov::InvalidParameterValueError)
      end
    end
  end

  describe "create an image edit with valid parameters", :vcr do
    let(:response) do
      Asimov::Client.new.images.create_edit(
        parameters: {
          image: image,
          mask: mask,
          prompt: prompt,
          size: size
        }
      )
    end
    let(:cassette) { "images edit #{image_filename} #{prompt}" }
    let(:prompt) { "A solid red Ruby on a blue background" }
    let(:image) { Utils.fixture_filename(filename: image_filename) }
    let(:image_filename) { "image.png" }
    let(:mask) { Utils.fixture_filename(filename: mask_filename) }
    let(:mask_filename) { "mask.png" }
    let(:size) { "256x256" }

    it "succeeds" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        expect(response.dig("data", 0, "url")).to include("dalle")
      end
    end
  end

  describe "create an image edit with an extra unsupported parameter", :vcr do
    let(:cassette) { "images edit with an unsupported parameter" }
    let(:prompt) { "A solid red Ruby on a blue background" }
    let(:image) { Utils.fixture_filename(filename: image_filename) }
    let(:image_filename) { "image.png" }
    let(:mask) { Utils.fixture_filename(filename: mask_filename) }
    let(:mask_filename) { "mask.png" }
    let(:size) { "256x256" }

    it "raises the expected error" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        expect do
          Asimov::Client.new.images.create_edit(
            parameters: {
              image: image,
              mask: mask,
              prompt: prompt,
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
    let(:image) { Utils.fixture_filename(filename: image_filename) }
    let(:image_filename) { "image.png" }
    let(:mask) { Utils.fixture_filename(filename: mask_filename) }
    let(:mask_filename) { "mask.png" }
    let(:size) { "1280x768" }

    it "raises the expected error" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        expect do
          Asimov::Client.new.images.create_edit(
            parameters: {
              image: image,
              mask: mask,
              prompt: prompt,
              size: size
            }
          )
        end.to raise_error(Asimov::InvalidParameterValueError)
      end
    end
  end

  describe "#create_variation", :vcr do
    let(:response) do
      Asimov::Client.new.images.create_variation(
        parameters: {
          image: image,
          n: 2,
          size: size
        }
      )
    end
    let(:cassette) { "images variations #{image_filename}" }
    let(:image) { Utils.fixture_filename(filename: image_filename) }
    let(:image_filename) { "image.png" }
    let(:size) { "256x256" }

    it "succeeds" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        expect(response.dig("data", 0, "url")).to include("dalle")
      end
    end
  end
end
