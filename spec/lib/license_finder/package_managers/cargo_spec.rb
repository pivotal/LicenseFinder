# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Cargo do
    subject { Cargo.new(project_path: Pathname('/fake/path')) }

    it_behaves_like 'a PackageManager'

    describe '.current_packages' do
      it 'lists all the current packages' do
        json = fixture_from('cargo.json')

        allow(Dir).to receive(:chdir).with(Pathname('/fake/path')) { |&block| block.call }
        allow(SharedHelpers::Cmd).to receive(:run)
          .with('cargo metadata --format-version=1')
          .and_return([json, '', cmd_success])

        expect(subject.current_packages.map(&:name)).to eq %w[license-finder log simple_logger]
      end
    end

    it 'should return the correct prepare command' do
      expect(Cargo.prepare_command).to eq('cargo fetch')
    end
  end
end
