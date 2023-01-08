require_relative "../../spec_helper"

RSpec.describe "Images API", type: :request do
  describe "#generate", :vcr do
    let(:response) do
      Asimov::Client.new.images.generate(
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
        r = JSON.parse(response.body)
        expect(r.dig("data", 0, "url")).to include("dalle")
      end
    end
  end

  describe "#edit", :vcr do
    let(:response) do
      Asimov::Client.new.images.edit(
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
        r = JSON.parse(response.body)
        expect(r.dig("data", 0, "url")).to include("dalle")
      end
    end
  end

  describe "#variations", :vcr do
    let(:response) do
      Asimov::Client.new.images.variations(
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
        r = JSON.parse(response.body)
        expect(r.dig("data", 0, "url")).to include("dalle")
      end
    end
  end
end
