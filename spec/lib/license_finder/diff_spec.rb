require 'spec_helper'

module LicenseFinder
  describe Diff do
    subject { Diff }

    let(:diff) { subject.compare(file1_content, file2_content) }

    def find_package(name)
      diff.find { |d| d.name == name }
    end

    describe '#compare' do
      context 'when a dependency is added' do
        let(:file1_content) do
          <<-CSV
          nokogiri, 1.6.6.2, MIT
          CSV
        end

        let(:file2_content) do
          <<-CSV
          nokogiri, 1.6.6.2, MIT
          rspec, 3.2.0, MIT
          CSV
        end

        it 'should create and set packages with added diff state' do
          rspec = find_package('rspec')
          expect(rspec.status).to eq 'added'
        end
      end

      context 'when a dependency is removed' do
        let(:file1_content) do
          <<-CSV
          nokogiri, 1.6.6.2, MIT
          rspec, 3.2.0, MIT
          CSV
        end

        let(:file2_content) do
          <<-CSV
          nokogiri, 1.6.6.2, MIT
          CSV
        end

        it 'should create and set packages with removed diff state' do
          rspec = find_package('rspec')
          expect(rspec.status).to eq 'removed'
        end
      end

      context 'when a dependency is unchanged' do
        let(:file1_content) do
          <<-CSV
          nokogiri, 1.6.6.2, MIT
          CSV
        end

        let(:file2_content) do
          <<-CSV
          nokogiri, 1.6.6.2, MIT
          CSV
        end

        it 'should create and set packages with unchanged diff state' do
          nokogiri = find_package('nokogiri')
          expect(nokogiri.status).to eq 'unchanged'
        end
      end

      context 'when there are all types of changes' do
        let(:file1_content) do
          <<-CSV
          rspec, 3.2.0, MIT
          nokogiri, 1.6.6.2, MIT
          fakefs, 0.6.7, MIT
          CSV
        end

        let(:file2_content) do
          <<-CSV
          nokogiri, 1.6.6.2, MIT
          minitest, 5.7.0, MIT
          fakefs, 0.6.7, BSD
          CSV
        end

        it 'should create and set packages diff states' do
          expect(find_package('minitest').status).to eq 'added'
          expect(find_package('rspec').status).to eq 'removed'
          expect(find_package('nokogiri').status).to eq 'unchanged'
        end
      end

      context 'when the version changes' do
        let(:file1_content) do
          <<-CSV
          rspec, 3.2.0, MIT
          CSV
        end

        let(:file2_content) do
          <<-CSV
          rspec, 3.3.0, MIT
          CSV
        end

        it 'should set the state to unchanged and record the version change' do
          rspec = find_package('rspec')

          expect(rspec.status).to eq('unchanged')
          expect(rspec.current_version).to eq('3.3.0')
          expect(rspec.previous_version).to eq('3.2.0')
        end
      end
    end
  end
end