# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Bundler do
    it_behaves_like 'a PackageManager'

    def bundle_list(without_groups = [])
      groups_arg = ''
      groups_arg = " --without-group #{without_groups.join(' ')}" unless without_groups.empty?

      output = `bundle list#{groups_arg}`
      output
        .each_line
        .map { |line| line.match(/\s*\*\s+(.+)\s+\((.+)\)/) }
        .compact
        .map { |matches| [matches[1], matches[2]] }
        .to_h
    end

    describe '.prepare_command' do
      subject { Bundler.new(project_path: Pathname.new('.')) }

      it 'returns the correct prepare method' do
        expect(subject.prepare_command).to eq('bundle install')
      end
    end

    describe '.current_packages' do
      around do |example|
        old_var = ENV['BUNDLE_GEMFILE']
        ENV.delete('BUNDLE_GEMFILE')
        example.run
        ENV['BUNDLE_GEMFILE'] = old_var
      end

      let(:package_manager) do
        Bundler.new(ignored_groups: Set.new(%w[development]), project_path: Pathname.new('.'))
      end

      subject { package_manager.current_packages }

      it 'should have the same dependencies as `bundle list`' do
        bundle_deps = bundle_list(%w[development])
        packages = subject
          .map { |pkg| [pkg.name, pkg.version] }
          .to_h
        # XXX: `bundle list` omits `bundler` as a dependency even when listed in the gemfile, exclude it when comparing
        packages.delete('bundler')
        expect(packages).to eq(bundle_deps)
      end
    end

    describe 'specifying a custom project path' do
      around do |example|
        old_var = ENV['BUNDLE_GEMFILE']
        ENV.delete('BUNDLE_GEMFILE')
        example.run
        ENV['BUNDLE_GEMFILE'] = old_var
      end

      let(:custom_gemfile) { fixture_path('custom_gemfile') }

      subject do
        Bundler.new(project_path: custom_gemfile, ignored_groups: Set.new(%w[development]))
      end

      it 'defaults to Gemfile/Gemfile.lock' do
        gemfile_path = custom_gemfile.join('Gemfile').expand_path
        expect(subject.possible_package_paths).to eq [gemfile_path]
        expect(subject.current_packages).not_to be_empty
      end
    end

    describe 'specifying a custom gemfile' do
      context 'with the BUNDLE_GEMFILE environment variable set' do
        around do |example|
          old_var = ENV['BUNDLE_GEMFILE']
          ENV['BUNDLE_GEMFILE'] = custom_gemfile.join('Gemfile-other').to_s
          example.run
          ENV['BUNDLE_GEMFILE'] = old_var
        end

        let(:custom_gemfile) { fixture_path('custom_gemfile') }

        subject do
          Bundler.new(project_path: custom_gemfile, ignored_groups: Set.new(%w[development]))
        end

        it 'uses the BUNDLE_GEMFILE variable to identify the gemfile' do
          gemfile_path = custom_gemfile.join('Gemfile-other').expand_path
          expect(subject.possible_package_paths).to eq [gemfile_path]
        end
      end
    end
  end
end
