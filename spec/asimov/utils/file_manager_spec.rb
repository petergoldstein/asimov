require_relative "../../spec_helper"

RSpec.describe Asimov::Utils::FileManager do
  describe ".open" do
    context "when the argument is a file name" do
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

    context "when the argument acts like a File" do
      let(:file_or_path) do
        fop = instance_double(File)
        allow(fop).to receive(:path)
        allow(fop).to receive(:read)
        fop
      end

      before do
        allow(File).to receive(:open).with(file_or_path)
      end

      it "just returns the argument" do
        expect(described_class.open(file_or_path)).to eq(file_or_path)
        expect(File).not_to have_received(:open).with(file_or_path)
      end
    end
  end
end
