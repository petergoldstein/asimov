require_relative "../../spec_helper"

RSpec.describe Asimov::Utils::FileManager do
  describe ".open" do
    let(:filename) { SecureRandom.hex(5) }

    context "when the file can successfuly be opened" do
      let(:file) { instance_double(File) }

      before do
        allow(File).to receive(:open).with(filename).and_return(file)
      end

      it "opens the file and returns with no error" do
        expect(described_class.open(filename)).to eq(file)
        expect(File).to have_received(:open).with(filename)
      end
    end

    context "when opening the file raises an Errno::ENOENT" do
      let(:file) { instance_double(File) }

      before do
        allow(File).to receive(:open).with(filename).and_raise(Errno::ENOENT)
      end

      it "catches the system error and raises an appropriate exception" do
        expect do
          described_class.open(filename)
        end.to raise_error(Asimov::FileCannotBeOpenedError)
        expect(File).to have_received(:open).with(filename)
      end
    end

    context "when opening the file raises an Errno::EPERM" do
      let(:file) { instance_double(File) }

      before do
        allow(File).to receive(:open).with(filename).and_raise(Errno::EPERM)
      end

      it "catches the system error and raises an appropriate exception" do
        expect do
          described_class.open(filename)
        end.to raise_error(Asimov::FileCannotBeOpenedError)
        expect(File).to have_received(:open).with(filename)
      end
    end

    context "when opening the file raises an Errno::EISDIR" do
      let(:file) { instance_double(File) }

      before do
        allow(File).to receive(:open).with(filename).and_raise(Errno::EISDIR)
      end

      it "catches the system error and raises an appropriate exception" do
        expect do
          described_class.open(filename)
        end.to raise_error(Asimov::FileCannotBeOpenedError)
        expect(File).to have_received(:open).with(filename)
      end
    end
  end
end
