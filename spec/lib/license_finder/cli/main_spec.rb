require "spec_helper"

module LicenseFinder
  module CLI
    describe Main do
      let(:decisions) do
        fake_file = Pathname.new("tmp/dependency_decisions.yml")
        Decisions.new(fake_file)
      end
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

      describe "#report" do
        let(:packages) { [Package.new('one dependency', "1.1")] }

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
          let(:packages) { [Package.new('one dependency')] }

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
