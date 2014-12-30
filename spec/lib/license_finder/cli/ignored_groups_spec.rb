require "spec_helper"

module LicenseFinder
  module CLI
    describe IgnoredGroups do
      let(:decisions) do
        fake_file = double(:decisions_file, open: nil)
        Decisions.new(fake_file)
      end

      before do
        allow(Decisions).to receive(:saved!) { decisions }
      end

      describe "list" do
        it "shows the ignored groups in the standard output" do
          decisions.ignore_group("development")

          expect(capture_stdout { subject.list }).to match /development/
        end
      end

      describe "add" do
        it "adds the specified group to the ignored groups list" do
          silence_stdout do
            subject.add("test")
          end
          expect(subject.decisions.ignored_groups).to eq ["test"].to_set
        end
      end

      describe "remove" do
        it "removes the specified group from the ignored groups list" do
          silence_stdout do
            subject.add("test")
            subject.remove("test")
          end
          expect(subject.decisions.ignored_groups).to be_empty
        end
      end
    end
  end
end
