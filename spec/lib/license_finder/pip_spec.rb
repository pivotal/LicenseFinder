require 'spec_helper'

module LicenseFinder
  describe Pip do
    describe '.current_packages' do
      it 'lists all the current dists' do
        allow(Pip).to receive(:`).with(/python/).and_return('[["jasmine", "1.3.1", "MIT"], ["jasmine-core", "1.3.1", "MIT"]]')

        current_packages = Pip.current_packages

        expect(current_packages.size).to eq(2)
        expect(current_packages.first).to be_a(Package)
      end

      it 'memoizes the current_packages' do
        allow(Pip).to receive(:`).with(/python/).and_return('[]').once

        Pip.current_packages
        Pip.current_packages
      end
    end

    describe '.active?' do
      let(:requirements) { Pathname.new('requirements.txt').expand_path }

      context 'with a requirements file' do
        before :each do
          allow(File).to receive(:exists?).with(requirements).and_return(true)
        end

        it 'returns true' do
          expect(Pip.active?).to eq(true)
        end
      end

      context 'without a requirements file' do
        before :each do
          allow(File).to receive(:exists?).with(requirements).and_return(false)
        end

        it 'returns false' do
          expect(Pip.active?).to eq(false)
        end
      end
    end
  end
end
