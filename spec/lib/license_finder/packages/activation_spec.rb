# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Activation do
    let(:package) { Package.new('p', nil) }
    let(:license) { License.find_by_name('l') }
    let(:activation) { described_class.new(package, license) }

    it 'reports that a license has been activated for a package' do
      subject = Activation::Basic.new(package, license)
      expect(subject.package).to eq package
      expect(subject.license).to eq license
    end

    describe Activation::FromDecision do
      it 'reports that it came from a decision' do
        expect(activation.sources).to eq ['from decision']
      end
    end

    describe Activation::FromSpec do
      it 'reports that it came from a spec' do
        expect(activation.sources).to eq ['from spec']
      end
    end

    describe Activation::FromFiles do
      it 'reports that it came from some files' do
        files = [double(:file, path: 'x'), double(:file, path: 'y')]
        activation = described_class.new(package, license, files)
        expect(activation.sources).to eq ["from file 'x'", "from file 'y'"]
      end
    end

    describe Activation::None do
      it 'reports that has no source' do
        expect(activation.sources).to eq []
      end
    end
  end
end
