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
        let(:file1_content) { "nokogiri,1.6.6.2,MIT" }
        let(:file2_content) { "nokogiri,1.6.6.2,MIT\nrspec,3.2.0,MIT" }

        it 'should create and set packages with added diff state' do
          rspec = find_package('rspec')
          expect(rspec.status).to eq :added
        end
      end

      context 'when a dependency is removed' do
        let(:file1_content) { "nokogiri,1.6.6.2,MIT\nrspec,3.2.0,MIT" }
        let(:file2_content) { "nokogiri,1.6.6.2,MIT" }

        it 'should create and set packages with removed diff state' do
          rspec = find_package('rspec')
          expect(rspec.status).to eq :removed
        end
      end

      context 'when a dependency is unchanged' do
        let(:file1_content) { "nokogiri,1.6.6.2,MIT" }
        let(:file2_content) { "nokogiri,1.6.6.2,MIT" }

        it 'should create and set packages with unchanged diff state' do
          nokogiri = find_package('nokogiri')
          expect(nokogiri.status).to eq :unchanged
        end
      end

      context 'when there are all types of changes' do
        let(:file1_content) { "rspec,3.2.0,MIT\nnokogiri,1.6.6.2,MIT\nfakefs,0.6.7,MIT" }
        let(:file2_content) { "nokogiri,1.6.6.2,MIT\nminitest,5.7.0,MIT\nfakefs,0.6.7,BSD" }

        it 'should create and set packages diff states' do
          expect(find_package('minitest').status).to eq :added
          expect(find_package('rspec').status).to eq :removed
          expect(find_package('nokogiri').status).to eq :unchanged
        end
      end

      context 'when the version changes' do
        let(:file1_content) { "rspec,3.2.0,MIT" }
        let(:file2_content) { "rspec,3.3.0,MIT" }

        it 'should set the state to unchanged and record the version change' do
          rspec = find_package('rspec')

          expect(rspec.status).to eq(:unchanged)
          expect(rspec.current_version).to eq('3.3.0')
          expect(rspec.previous_version).to eq('3.2.0')
        end
      end

      context 'when the license changes' do
        let(:file1_content) { "rspec,3.2.0,MIT" }
        let(:file2_content) { "rspec,3.3.0,GPLv2" }

        it 'should set the state to unchanged and record the version change' do
          rspec_old = diff.find {|p| p.previous_version == '3.2.0'}
          rspec_new = diff.find {|p| p.current_version == '3.3.0'}

          expect(rspec_old.status).to eq(:removed)
          expect(rspec_old.current_version).to eq(nil)
          expect(rspec_old.previous_version).to eq('3.2.0')

          expect(rspec_new.status).to eq(:added)
          expect(rspec_new.current_version).to eq('3.3.0')
          expect(rspec_new.previous_version).to eq(nil)
        end
      end

      context 'when the files are merged reports' do
        let(:file1_content) { "rspec,3.2.0,MIT,\"/path/to/project1,/path/to/project2\"" }
        let(:file2_content) { "rspec,3.2.0,MIT,\"/path/to/project1,/path/to/project2\"\nrails,4.2.0,MIT,/path/to/project1" }

        it 'should show the diff of the reports' do
          rspec = find_package('rspec')
          expect(rspec.status).to eq(:unchanged)
          expect(rspec.current_version).to eq('3.2.0')
          expect(rspec.previous_version).to eq('3.2.0')
          paths = ['/path/to/project1', '/path/to/project2'].map { |p| File.absolute_path(p) }
          expect(rspec.subproject_paths).to match_array(paths)

          rails = find_package('rails')
          expect(rails.status).to eq(:added)
          expect(rails.current_version).to eq('4.2.0')
          expect(rails.previous_version).to eq(nil)
          paths = ['/path/to/project1'].map { |p| File.absolute_path(p) }
          expect(rails.subproject_paths).to match_array(paths)
        end
      end
    end
  end
end
