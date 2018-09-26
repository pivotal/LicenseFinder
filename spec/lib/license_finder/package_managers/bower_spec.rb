# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Bower do
    subject { Bower.new(project_path: Pathname('/fake/path')) }

    it_behaves_like 'a PackageManager'

    describe '.current_packages' do
      it 'lists all the current packages' do
        json = fixture_from('bower.json')

        allow(Dir).to receive(:chdir).with(Pathname('/fake/path')) { |&block| block.call }
        allow(SharedHelpers::Cmd).to receive(:run)
          .with('bower list --json -l action --allow-root')
          .and_return([json, '', cmd_success])

        expect(subject.current_packages.map { |p| [p.name, p.install_path] }).to eq [
          %w[dependency-library /path/to/thing], %w[another-dependency /path/to/thing2]
        ]
      end
    end

    it 'should return the correct prepare command' do
      expect(Bower.prepare_command).to eq('bower install')
    end
  end
end
