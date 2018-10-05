# frozen_string_literal: true

require 'spec_helper'
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
      let(:configuration) { double(:configuration, valid_project_path?: true) }
      let(:found_any_packages) { true }
      let(:license_finder_instance) do
        methods = { unapproved: unapproved_dependencies, blacklisted: [],
                    project_name: 'taco stand', config: configuration,
                    any_packages?: found_any_packages, prepare_projects: nil }
        double(:license_finder, methods)
      end

      let(:license_aggregator_instance) do
        methods = { unapproved: unapproved_dependencies, blacklisted: blacklisted,
                    any_packages?: found_any_packages }
        double(:license_aggregator, methods)
      end

      let(:license) { double(:license, name: 'thing') }
      let(:unapproved_dependencies) { [double(:dependency, name: 'a dependency', version: '2.4.1', missing?: false, licenses: [license])] }
      let(:blacklisted) { [] }

      before do
        logger = double('Logger', info: true, debug: true)
        allow(LicenseFinder::Logger).to receive(:new).and_return(logger)
      end

      before do
        allow(DecisionsFactory).to receive(:decisions) { decisions }
        allow(DecisionApplier).to receive(:new) { decision_applier }
      end

      describe 'default' do
        it 'checks for action items' do
          decisions.add_package('a dependency', nil)
          aggregator = double(:license_aggregator)
          expect(aggregator).to receive(:unapproved)
          expect(aggregator).to receive(:blacklisted)
          expect(aggregator).to receive(:any_packages?)
          allow(LicenseFinder::LicenseAggregator).to receive(:new).and_return(aggregator)
          silence_stdout do
            expect { described_class.start(['--quiet']) }.to raise_error(SystemExit)
          end
        end
      end

      describe 'cli options' do
        let(:config_options) do
          [
            '--decisions_file=whatever.yml',
            '--project_path=../other_project',
            '--gradle_command=do_things',
            '--rebar_command=do_other_things',
            '--rebar_deps_dir=rebar_dir',
            '--mix_command=surprise_me',
            '--mix_deps_dir=mix_dir',
            '--prepare',
            '--log_directory=some_logs'
          ]
        end

        let(:logger_options) do
          [
            '--debug'
          ]
        end

        let(:parsed_config) do
          {
            decisions_file: 'whatever.yml',
            project_path: '../other_project',
            gradle_command: 'do_things',
            rebar_command: 'do_other_things',
            rebar_deps_dir: 'rebar_dir',
            mix_command: 'surprise_me',
            mix_deps_dir: 'mix_dir',
            prepare: true,
            log_directory: 'some_logs',
            logger: { mode: LicenseFinder::Logger::MODE_INFO }
          }
        end

        it 'passes the config options to the new LicenseFinder::LicenseAggregator instance' do
          stubs = { valid_project_path?: true, project_path: Pathname('../other_project'),
                    decisions_file_path: Pathname('../other_project'), aggregate_paths: nil, recursive: false, format: nil, columns: nil, strict_matching: false }
          configuration = double(:configuration, stubs)
          allow(LicenseFinder::Configuration).to receive(:with_optional_saved_config).and_return(configuration)
          expect(LicenseFinder::LicenseAggregator).to receive(:new).with(configuration, anything).and_return(license_finder_instance)
          silence_stdout do
            expect { described_class.start(config_options) }.to raise_error(SystemExit)
          end
        end
      end

      describe '#report' do
        let(:packages) { [Package.new('one dependency', '1.1')] }

        def report
          capture_stdout { subject.report }
        end

        it 'reports acknowleged dependencies' do
          expect(report).to eq "\"one dependency\", 1.1, unknown\n"
        end

        it 'will output a specific format' do
          subject.options = { 'format' => 'markdown' }
          expect(report).to include '## Action'
        end

        it 'will output a custom csv' do
          subject.options = { 'format' => 'csv', 'columns' => %w[name version] }

          expect(report).to eq "one dependency,1.1\n"
        end

        context 'when the package is a nuget package' do
          let(:packages) { [NugetPackage.new('one dependency', '1.1')] }

          it 'will includes package_manager for csv report' do
            subject.options = { 'format' => 'csv', 'columns' => %w[name version package_manager] }

            expect(report).to eq "one dependency,1.1,Nuget\n"
          end
        end

        context 'in html reports' do
          before do
            subject.options = { 'format' => 'html' }
          end

          context 'when the project has a name' do
            before { decisions.name_project('given project name') }

            it 'should show the project name' do
              expect(report).to include 'given project name'
            end
          end

          context 'when the project has no name' do
            before { allow_any_instance_of(Pathname).to receive(:basename).and_return('a_project') }

            it 'should default to the directory name' do
              expect(report).to include 'a_project'
            end
          end
        end

        context 'when the --save option is passed' do
          it 'calls report method and calls save_report' do
            subject.options = { 'save' => 'license_report', 'format' => 'text' }
            expect(subject).to receive(:report).and_call_original
            expect(subject).to receive(:save_report)

            subject.report
          end

          context 'when file name is not specified (--save)' do
            it 'creates report that is called the default file name' do
              provided_by_thor_as_default_name = 'license_report' # ####FIX ME
              subject.options = { 'save' => provided_by_thor_as_default_name, 'format' => 'text' }
              expect(subject).to receive(:report).and_call_original
              expect(subject).to receive(:save_report).with(instance_of(String), 'license_report')

              subject.report
            end

            it "saves the output report to default file ('license_report.txt') in project root" do
              mock_file = double(:file)
              expect(File).to receive(:open).with('license_report.txt', 'w').and_yield(mock_file)
              expect(mock_file).to receive(:write).with('content of file')

              subject.send(:save_report, 'content of file', 'license_report.txt')
            end
          end

          context "when file name is specified (--save='FILENAME')" do
            it 'saves with a specified file name' do
              subject.options = { 'save' => 'my_report', 'format' => 'text' }
              expect(subject).to receive(:report).and_call_original
              expect(subject).to receive(:save_report).with(instance_of(String), 'my_report')

              subject.report
            end
          end
        end

        context 'when the --save option is not passed' do
          it 'calls report method and does not call save_report' do
            subject.options = { 'format' => 'text' }
            expect(subject).to receive(:report).and_call_original
            expect(subject).not_to receive(:save_report)
            expect(subject).to receive(:report_of)

            report
          end
        end
      end

      describe '#action_items' do
        def action_items
          subject.options = { 'quiet' => true, 'format' => 'text' }
          subject.action_items
        end

        context "with a directory that doesn't have any detected packages" do
          let(:found_any_packages) { false }

          before do
            allow(LicenseFinder::LicenseAggregator).to receive(:new).and_return(license_aggregator_instance)
          end

          it 'reports that no dependencies were recognized' do
            result = capture_stdout do
              expect { action_items }.to raise_error(SystemExit)
            end
            expect(result).to match /no dependencies recognized/i
          end
        end

        context 'with unapproved dependencies' do
          before do
            allow(LicenseFinder::LicenseAggregator).to receive(:new).and_return(license_aggregator_instance)
          end

          it 'reports unapproved dependencies' do
            result = capture_stdout do
              expect { action_items }.to raise_error(SystemExit)
            end
            expect(result).to match /dependencies/i
            expect(result).to match /a dependency/
          end
        end

        context 'with blacklisted dependencies' do
          let(:blacklisted) { [Package.new('blacklisted', '1.0', spec_licenses: ['GPLv3'])] }
          before do
            allow(LicenseFinder::LicenseAggregator).to receive(:new).and_return(license_aggregator_instance)
          end

          it 'reports blacklisted dependencies' do
            result = capture_stdout do
              expect { action_items }.to raise_error(SystemExit)
            end
            expect(result).to include "Blacklisted dependencies:\nblacklisted, 1.0, GPLv3"
          end
        end

        context 'with no unapproved dependencies' do
          let(:unapproved_dependencies) { [] }

          before do
            allow(LicenseFinder::LicenseAggregator).to receive(:new).and_return(license_aggregator_instance)
          end

          it 'reports that all dependencies are approved' do
            result = capture_stdout do
              expect { action_items }.not_to raise_error
            end
            expect(result).to match /approved/i
          end
        end
      end
    end
  end
end
