# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe GoDep do
    let(:options) { {} }
    subject { GoDep.new(options.merge(project_path: Pathname('/fake/path'))) }

    it_behaves_like 'a PackageManager'

    let(:content_with_duplicates) do
      FakeFS.without do
        fixture_from('godep_with_duplicates.json')
      end
    end

    let(:content) do
      FakeFS.without do
        fixture_from('godep.json')
      end
    end

    describe '#current_packages' do
      before do
        FakeFS.activate!
        FileUtils.mkdir_p '/fake/path/Godeps'
        File.write('/fake/path/Godeps/Godeps.json', content)

        @orig_gopath = ENV['GOPATH']
        ENV['GOPATH'] = '/fake/go/path'
      end

      after do
        FakeFS.deactivate!
        ENV['GOPATH'] = @orig_gopath
      end

      it 'sets the homepage for packages' do
        packages = subject.current_packages

        expect(packages[0].homepage).to eq('github.com/pivotal/foo')
        expect(packages[1].homepage).to eq('github.com/pivotal/bar')
        expect(packages[2].homepage).to eq('code.google.com/foo/bar')
      end

      context 'when the GoDep returns entries with same sha and common base path' do
        let(:options) { { go_full_version: true } }
        let(:all_packages) { subject.current_packages }

        before do
          File.write('/fake/path/Godeps/Godeps.json', content_with_duplicates)
        end

        it 'filters dependencies based on same shas and common paths' do
          expect(all_packages.length).to eq(3)
        end

        it 'removes duplicate entries having same sha with common base path' do
          packages_with_common_path = all_packages.select do |package|
            package.name == 'github.com/foo/baz'
          end

          expect(packages_with_common_path.length).to eq(1)
          expect(packages_with_common_path.first.name).to eq('github.com/foo/baz')
          expect(packages_with_common_path.first.version).to eq('28838aae6e8158e3695cf90e2f0ed2498b68ee1d')
        end

        it 'shows entries having same shas with no common base path' do
          packages_with_same_sha = all_packages.select do |package|
            package.version == '28838aae6e8158e3695cf90e2f0ed2498b68ee1d'
          end

          expect(packages_with_same_sha.length).to eq(2)
          expect(packages_with_same_sha[0].name).to eq('github.com/foo/baz')
          expect(packages_with_same_sha[1].name).to eq('code.google.com/foo/bar')
        end

        it 'shows entries with different shas' do
          expect(all_packages.last.name).to eq('github.com/foo/baz/sub3')
          expect(all_packages.last.version).to eq('28838aae6e8158e3695cf90e2f0ed2498b68ee1e')
        end
      end

      context 'when dependencies are vendored' do
        before do
          allow(FileTest).to receive(:directory?).with('/fake/path/Godeps/_workspace').and_return(true)
        end

        it 'should return an array of packages' do
          packages = subject.current_packages
          expect(packages.map(&:name)).to include('github.com/pivotal/foo', 'github.com/pivotal/bar')
          expect(packages.map(&:version)).to include('61164e4', '3245708')
        end

        it 'should set the install_path to the vendored directory' do
          packages = subject.current_packages
          expect(packages[0].install_path).to eq('/fake/path/Godeps/_workspace/src/github.com/pivotal/foo')
          expect(packages[1].install_path).to eq('/fake/path/Godeps/_workspace/src/github.com/pivotal/bar')
        end

        context 'when requesting the full version' do
          let(:options) { { go_full_version: true } }

          it 'list the dependencies with full version' do
            expect(subject.current_packages.map(&:version)).to eq %w[
              61164e49940b423ba1f12ddbdf01632ac793e5e9
              3245708abcdef234589450649872346783298736
              3245708abcdef234589450649872346783298735
            ]
          end
        end
      end

      context 'when dependencies are not vendored' do
        before do
          @orig_gopath = ENV['GOPATH']
          ENV['GOPATH'] = '/fake/go/path'
        end

        after do
          ENV['GOPATH'] = @orig_gopath
        end

        it 'should return an array of packages' do
          packages = subject.current_packages
          expect(packages.map(&:name)).to include('github.com/pivotal/foo', 'github.com/pivotal/bar')
          expect(packages.map(&:version)).to include('61164e4', '3245708')
        end

        it 'should set the install_path to the GOPATH' do
          packages = subject.current_packages
          expect(packages[0].install_path).to eq('/fake/go/path/src/github.com/pivotal/foo')
          expect(packages[1].install_path).to eq('/fake/go/path/src/github.com/pivotal/bar')
        end
      end
    end
  end
end
