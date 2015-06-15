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
      let(:license_finder_instance) { double(:license_finder, unapproved: [unapproved_dependency], project_name: 'taco stand') }
      let(:license) { double(:license, name: "thing") }
      let(:unapproved_dependency) { double(:dependency, name: "a dependency", version: "2.4.1", missing?: false, licenses: [license]) }

      before do
        allow(Decisions).to receive(:saved!) { decisions }
        allow(DecisionApplier).to receive(:new) { decision_applier }
      end

      describe "default" do
        it "checks for action items" do
          decisions.add_package("a dependency", nil)
          expect_any_instance_of(LicenseFinder::Core).to receive(:unapproved).and_return([unapproved_dependency])
          silence_stdout do
            expect { described_class.start(["--quiet"]) }.to raise_error(SystemExit)
          end
        end
      end

      describe "cli options" do
        let(:config_options) { [
          "--decisions_file=whatever.yml",
          "--project_path=../other_project",
          "--gradle_command=do_things",
          "--rebar_command=do_other_things",
          "--rebar_deps_dir=rebar_dir",
          "--save"
        ] }
        let(:logger_options) {
          [
            '--quiet',
            '--debug'
          ]
        }
        let(:parsed_config) { {
          decisions_file: 'whatever.yml',
          project_path: '../other_project',
          gradle_command: 'do_things',
          rebar_command: 'do_other_things',
          rebar_deps_dir: 'rebar_dir',
          save: true,
          logger: {}
        } }

        it "passes the config options to the new LicenseFinder::Core instance" do
          expect(LicenseFinder::Core).to receive(:new).with(parsed_config).and_return(license_finder_instance)
          silence_stdout do
            expect { described_class.start(config_options) }.to raise_error(SystemExit)
          end
        end

        it "passes the logger options to the new LicenseFinder::Core instance" do
          expect(LicenseFinder::Core).to receive(:new).with({logger: {debug: true, quiet: true}}).and_return(license_finder_instance)
          silence_stdout do
            expect { described_class.start(logger_options) }.to raise_error(SystemExit)
          end
        end
      end

      describe "#report" do
        let(:packages) { [Package.new('one dependency', "1.1")] }

        def report
          capture_stdout { subject.report }
        end

        it "reports acknowleged dependencies" do
          expect(report).to eq "\"one dependency\", 1.1, unknown\n"
        end

        it "will output a specific format" do
          subject.options = {format: 'markdown'}

          expect(report).to include "## Action"
        end

        it "will output a custom csv" do
          subject.options = {format: 'csv', columns: ['name', 'version']}

          expect(report).to eq "one dependency,1.1\n"
        end

        context "when the --save option is passed" do
          it "calls report method and responds to save flag" do
            subject.options = {save: "--save", format: 'text'}
            expect(subject).to receive(:report).and_call_original
            expect(subject).to receive(:save_report)

            subject.report
          end

          it "saves the output to license_report file in project root" do
            mock_file = double(:file)
            expect(File).to receive(:open).with("license_report.txt", "w").and_yield(mock_file)
            expect(mock_file).to receive(:write).with("content of file")

            subject.send(:save_report, "content of file", "license_report.txt")
          end
        end

        context "in html reports" do
          before do
            subject.options = {format: 'html'}
          end

          context "when the project has a name" do
            before { decisions.name_project("given project name") }

            it "should show the project name" do
              expect(report).to include "given project name"
            end
          end

          context "when the project has no name" do
            before { allow(Dir).to receive(:getwd).and_return("/path/to/a_project") }

            it "should default to the directory name" do
              expect(report).to include "a_project"
            end
          end
        end
      end

      describe "#action_items" do
        def action_items
          subject.options = {quiet: true, format: 'text'}
          subject.action_items
        end

        context "with unapproved dependencies" do
          let(:packages) { [Package.new('one dependency')] }

          it "reports unapproved dependencies" do
            result = capture_stdout do
              expect { action_items }.to raise_error(SystemExit)
            end
            expect(result).to match /dependencies/i
            expect(result).to match /one dependency/
          end
        end

        it "reports that all dependencies are approved" do
          result = capture_stdout do
            expect { action_items }.not_to raise_error
          end
          expect(result).to match /approved/i
        end
      end
    end
  end
end
