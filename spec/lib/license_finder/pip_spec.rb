require 'spec_helper'

module LicenseFinder
  describe Pip do
    describe '.current_dists' do
      it 'lists all the current dists' do
        allow(Pip).to receive(:`).with(/python/).and_return('[["jasmine", "1.3.1", "MIT"], ["jasmine-core", "1.3.1", "MIT"]]')

        current_dists = Pip.current_dists

        expect(current_dists.size).to eq(2)
        expect(current_dists.first).to be_a(Package)
      end

      it 'memoizes the current_dists' do
        allow(Pip).to receive(:`).with(/python/).and_return('[]').once

        Pip.current_dists
        Pip.current_dists
      end
    end

    describe '.has_requirements' do
      let(:requirements) { Pathname.new('requirements.txt').expand_path }

      context 'with a requirements file' do
        before :each do
          allow(File).to receive(:exists?).with(requirements).and_return(true)
        end

        it 'returns true' do
          expect(Pip.has_requirements?).to eq(true)
        end
      end

      context 'without a requirements file' do
        before :each do
          allow(File).to receive(:exists?).with(requirements).and_return(false)
        end

        it 'returns false' do
          expect(Pip.has_requirements?).to eq(false)
        end
      end
    end
  end
end
