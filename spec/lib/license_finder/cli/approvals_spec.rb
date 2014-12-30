require "spec_helper"

module LicenseFinder
  module CLI
    describe Approvals do
      let(:decisions) do
        fake_file = double(:decisions_file, open: nil)
        Decisions.new(fake_file)
      end

      before do
        allow(Decisions).to receive(:saved!) { decisions }
      end

      describe "#add" do
        it "approves the requested gem" do
          silence_stdout do
            subject.add 'foo'
          end
          expect(subject.decisions).to be_approved "foo"
        end

        it "approves multiple dependencies" do
          silence_stdout do
            subject.add 'foo', 'bar'
          end
          expect(subject.decisions).to be_approved "foo"
          expect(subject.decisions).to be_approved "bar"
        end

        it "raises a warning if no dependency was specified" do
          silence_stdout do
            expect { subject.add }.to raise_error(ArgumentError)
          end
        end

        it "sets approver and approval message" do
          expect(decisions).to receive(:approve).with("foo", hash_including(who: "Julian", why:  "We really need this"))

          silence_stdout do
            Main.start(["approval", "add", "--who", "Julian", "--why", "We really need this", "foo"])
          end
        end
      end

      describe "remove" do
        it "unapproves the specified dependency" do
          silence_stdout do
            subject.add("test")
            subject.remove("test")
          end
          expect(subject.decisions).not_to be_approved "test"
        end

        it "is cumulative" do
          silence_stdout do
            subject.add("test")
            subject.remove("test")
            subject.add("test")
          end
          expect(subject.decisions).to be_approved "test"
        end
      end
    end
  end
end
