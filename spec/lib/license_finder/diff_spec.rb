require 'spec_helper'

module LicenseFinder
  describe Diff do
    subject { Diff }

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
          diffed_deps = subject.compare(file1_content, file2_content)

          rspec = diffed_deps.find {|dep| dep.name == 'rspec' }
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
          diffed_deps = subject.compare(file1_content, file2_content)

          rspec = diffed_deps.find {|dep| dep.name == 'rspec' }
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
          diffed_deps = subject.compare(file1_content, file2_content)

          nokogiri = diffed_deps.find {|dep| dep.name == 'nokogiri' }
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
          diffed_deps = subject.compare(file1_content, file2_content)

          minitest = diffed_deps.find {|dep| dep.name == 'minitest' }
          expect(minitest.status).to eq 'added'
          rspec = diffed_deps.find {|dep| dep.name == 'rspec' }
          expect(rspec.status).to eq 'removed'
          nokogiri = diffed_deps.find {|dep| dep.name == 'nokogiri' }
          expect(nokogiri.status).to eq 'unchanged'
        end
        end

      context 'when there are all types of changes' do
        let(:file1_content) do
          <<-CSV
          rspec, 3.2.0, MIT
          nokogiri, 1.6.6.2, BSD
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
          diffed_deps = subject.compare(file1_content, file2_content)

          minitest = diffed_deps.find {|dep| dep.name == 'minitest' }
          expect(minitest.status).to eq 'added'
          rspec = diffed_deps.find {|dep| dep.name == 'rspec' }
          expect(rspec.status).to eq 'removed'
          nokogiri = diffed_deps.find {|dep| dep.name == 'nokogiri' }
          expect(nokogiri.status).to eq 'unchanged'
        end
      end
    end
  end
end