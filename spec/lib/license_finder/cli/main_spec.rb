require "spec_helper"

module LicenseFinder
  module CLI
    describe Main do
      let(:decisions) { Decisions.new }
      let(:packages) { [] }
      let!(:decision_applier) do
        DecisionApplier.new(
          decisions: decisions,
          packages: packages
        )
      end

      before do
        allow(Decisions).to receive(:saved!) { decisions }
        allow(DecisionApplier).to receive(:new) { decision_applier }
      end

      describe "default" do
        it "checks for action items" do
          decisions.add_package("a dependency", nil)

          silence_stdout do
            expect { described_class.start(["--quiet"]) }.to raise_error(SystemExit)
          end
        end
      end

      describe "#license" do
        it "updates the license on the requested gem" do
          silence_stdout do
            subject.license 'foo', 'foo_gem'
          end
          expect(subject.decisions.license_of("foo_gem").name).to eq "foo"
        end
      end

      describe "#approve" do
        it "approves the requested gem" do
          silence_stdout do
            subject.approve 'foo'
          end
          expect(subject.decisions).to be_approved "foo"
        end

        it "approves multiple gem" do
          silence_stdout do
            subject.approve 'foo', 'bar'
          end
          expect(subject.decisions).to be_approved "foo"
          expect(subject.decisions).to be_approved "bar"
        end

        it "raises a warning if no gem was specified" do
          silence_stdout do
            expect { subject.approve }.to raise_error(ArgumentError)
          end
        end

        it "sets approver and approval message" do
          expect(decisions).to receive(:approve).with("foo", hash_including(who: "Julian", why:  "We really need this"))

          silence_stdout do
            Main.start(["approve", "--who", "Julian", "--why", "We really need this", "foo"])
          end
        end
      end

      describe "#report" do
        let(:packages) { [ManualPackage.new('one dependency', "1.1")] }

        it "reports acknowleged dependencies" do
          result = capture_stdout do
            Main.start(["report"])
          end
          expect(result).to eq "\"one dependency\", 1.1, other\n"
        end

        it "will output a specific format" do
          result = capture_stdout do
            Main.start(%w[report --format markdown])
          end

          expect(result).to include "## Action"
        end

        it "will output a custom csv" do
          result = capture_stdout do
            Main.start(%w[report --format csv --columns name version])
          end

          expect(result).to eq "one dependency,1.1\n"
        end
      end

      describe "#action_items" do
        context "with unapproved dependencies" do
          let(:packages) { [ManualPackage.new('one dependency')] }

          it "reports unapproved dependencies" do
            result = capture_stdout do
              expect do
                Main.start(%w[action_items --quiet])
              end.to raise_error(SystemExit)
            end
            expect(result).to match /dependencies/i
            expect(result).to match /one dependency/
          end
        end

        it "reports that all dependencies are approved" do
          result = capture_stdout do
            expect do
              Main.start(%w[action_items --quiet])
            end.not_to raise_error
          end
          expect(result).to match /approved/i
        end
      end
    end
  end
end
