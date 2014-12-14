require 'spec_helper'

module LicenseFinder
  describe Decisions do
    let(:mit) { License.find_by_name("MIT") }

    describe ".add_package" do
      it "adds to list of packages" do
        packages = subject.add_package("dep").packages
        expect(packages.size).to eq 1
        expect(packages.first.name).to eq "dep"
      end

      it "includes optional version" do
        packages = subject.add_package("dep", "0.2.0").packages
        expect(packages.first.version).to eq "0.2.0"
      end
    end

    describe ".remove_package" do
      it "drops a package" do
        packages = subject.
          add_package("dep").
          remove_package("dep").
          packages
        expect(packages.size).to eq 0
      end

      it "does nothing if package was never added" do
        packages = subject.
          remove_package("dep").
          packages
        expect(packages.size).to eq 0
      end
    end

    describe ".license" do
      it "will report license for a dependency" do
        license = subject.
          license("dep", mit).
          license_of("dep")
        expect(license).to eq mit
      end
    end

    describe ".approve" do
      it "will report a dependency as approved" do
        decisions = subject.approve("dep")
        expect(decisions).to be_approved("dep")
      end

      it "will not report a dependency as approved by default" do
        expect(subject).not_to be_approved("dep")
      end
    end

    describe ".whitelist" do
      it "will report the given license as approved" do
        decisions = subject.
          add_package("dep", mit).
          whitelist(mit)
        expect(decisions).to be_approved_license(mit)
      end
    end

    describe ".unwhitelist" do
      it "will not report the given license as approved" do
        decisions = subject.
          whitelist(mit).
          unwhitelist(mit)
        expect(decisions).not_to be_approved_license(mit)
      end

      it "is cumulative" do
        decisions = subject.
          whitelist(mit).
          unwhitelist(mit).
          whitelist(mit)
        expect(decisions).to be_approved_license(mit)
      end
    end

    describe ".ignore" do
      it "will report ignored dependencies" do
        decisions = subject.ignore("dep")
        expect(decisions).to be_ignored("dep")
      end
    end

    describe ".heed" do
      it "will not report heeded dependencies" do
        decisions = subject.
          ignore("dep").
          heed("dep")
        expect(decisions).not_to be_ignored("dep")
      end

      it "is cumulative" do
        decisions = subject.
          ignore("dep").
          heed("dep").
          ignore("dep")
        expect(decisions).to be_ignored("dep")
      end
    end

    describe ".ignore_group" do
      it "will report ignored groups" do
        decisions = subject.
          ignore_group("development")
        expect(decisions).to be_ignored_group("development")
      end
    end

    describe ".heed_group" do
      it "will not report heeded groups" do
        decisions = subject.
          ignore_group("development").
          heed_group("development")
        expect(decisions).not_to be_ignored_group("development")
      end

      it "is cumulative" do
        decisions = subject.
          ignore_group("development").
          heed_group("development").
          ignore_group("development")
        expect(decisions).to be_ignored_group("development")
      end
    end
  end
end
