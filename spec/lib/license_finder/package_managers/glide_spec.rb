require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Glide do
    it_behaves_like "a PackageManager"
    describe "#current_packages" do
      subject { Glide.new(project_path: Pathname('/app'), logger: double(:logger, active: nil)) }

      it "returns the packages described by glide.lock" do
        FakeFS do
          FileUtils.mkdir_p '/app'
          File.write(subject.package_path.to_s,
%{imports:
- name: some-package-name
  version: 123abc
  repo: example.com
- name: another-package-name
  version: 456xyz})

          expect(subject.current_packages.length).to eq 2

          expect(subject.current_packages.first.name). to eq 'some-package-name'
          expect(subject.current_packages.first.version). to eq '123abc'

          expect(subject.current_packages.last.name). to eq 'another-package-name'
          expect(subject.current_packages.last.version). to eq '456xyz'
        end
      end
    end
  end
end
