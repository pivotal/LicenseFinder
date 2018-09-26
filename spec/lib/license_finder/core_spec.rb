# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Core do
    let(:logger) { LicenseFinder::Logger.new }
    let(:configuration) { LicenseFinder::Configuration.new(options, {}) }
    let(:license_finder) { described_class.new(configuration) }
    let(:pathname) { Pathname.pwd + Pathname(options[:project_path]) }
    let(:scanner) { Scanner.new }

    before do
      allow(logger).to receive(LicenseFinder::Logger::MODE_INFO)
      allow(logger).to receive(LicenseFinder::Logger::MODE_DEBUG)
      allow(Logger).to receive(:new).and_return(logger)
      allow(Scanner).to receive(:new).and_return(scanner)
    end

    describe '#unapproved' do
      let(:options) do
        {
          logger: {},
          project_path: 'other_directory',
          gradle_command: 'just_do_it',
          rebar_command: 'do_it',
          rebar_deps_dir: 'nowhere/deps',
          mix_command: 'mix_it',
          mix_deps_dir: 'mixes_in_here/deps',
          prepare: 'prepare'
        }
      end
      let(:package_options) do
        {
          logger: logger,
          project_path: configuration.project_path,
          ignored_groups: Set.new,
          go_full_version: nil,
          gradle_command: configuration.gradle_command,
          gradle_include_groups: nil,
          maven_include_groups: nil,
          maven_options: nil,
          pip_requirements_path: nil,
          rebar_command: configuration.rebar_command,
          rebar_deps_dir: configuration.rebar_deps_dir,
          mix_command: configuration.mix_command,
          mix_deps_dir: configuration.mix_deps_dir,
          prepare: configuration.prepare,
          prepare_no_fail: nil,
          sbt_include_groups: nil
        }
      end

      it 'delegates to the decision_applier' do
        decision_applier = double(:decision_applier)
        allow(license_finder).to receive(:decision_applier).and_return(decision_applier)
        expect(decision_applier).to receive(:unapproved)
        license_finder.unapproved
      end

      it 'passes through options when fetching current packages' do
        expect(scanner).to receive(:active_packages).and_return([])
        license_finder.unapproved
      end
    end
  end
end
