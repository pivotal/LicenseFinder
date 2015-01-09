require 'spec_helper'

module LicenseFinder
  describe Decisions do
    describe ".add_package" do
      it "adds to list of packages" do
        packages = subject.add_package("dep", nil).packages
        expect(packages.map(&:name)).to eq ["dep"]
      end

      it "includes optional version" do
        packages = subject.add_package("dep", "0.2.0").packages
        expect(packages.first.version).to eq "0.2.0"
      end
    end

    describe ".remove_package" do
      it "drops a package" do
        packages = subject.
          add_package("dep", nil).
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
          license("dep", "MIT").
          licenses_of("dep").first
        expect(license).to eq License.find_by_name("MIT")
      end

      it "will report multiple licenses" do
        licenses = subject.
          license("dep", "MIT").
          license("dep", "GPL").
          licenses_of("dep")
        expect(licenses).to eq [
          License.find_by_name("MIT"),
          License.find_by_name("GPL"),
        ].to_set
      end

      it "adapts names" do
        license = subject.
          license("dep", "Expat").
          licenses_of("dep").first
        expect(license).to eq License.find_by_name("MIT")
      end
    end

    describe ".unlicense" do
      it "will not report the given dependency as licensed" do
        licenses = subject.
          license("dep", "MIT").
          unlicense("dep", "MIT").
          licenses_of("dep")
        expect(licenses).to be_empty
      end

      it "will only remove the specified license" do
        licenses = subject.
          license("dep", "MIT").
          license("dep", "GPL").
          unlicense("dep", "MIT").
          licenses_of("dep")
        expect(licenses).to eq [License.find_by_name("GPL")].to_set
      end

      it "is cumulative" do
        license = subject.
          license("dep", "MIT").
          unlicense("dep", "MIT").
          license("dep", "MIT").
          licenses_of("dep").first
        expect(license).to eq License.find_by_name("MIT")
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

    describe ".unapprove" do
      it "will not report the given dependency as approved" do
        decisions = subject.
          approve("dep").
          unapprove("dep")
        expect(subject).not_to be_approved("dep")
      end

      it "is cumulative" do
        decisions = subject.
          approve("dep").
          unapprove("dep").
          approve("dep")
        expect(subject).to be_approved("dep")
      end
    end

    describe ".whitelist" do
      it "will report the given license as approved" do
        decisions = subject.whitelist("MIT")
        expect(decisions).to be_whitelisted(License.find_by_name("MIT"))
      end

      it "adapts names" do
        decisions = subject.whitelist("Expat")
        expect(decisions).to be_whitelisted(License.find_by_name("MIT"))
      end

      it "adds to list" do
        decisions = subject.whitelist("MIT")
        expect(decisions.whitelisted).to eq(Set.new([License.find_by_name("MIT")]))
      end
    end

    describe ".unwhitelist" do
      it "will not report the given license as approved" do
        decisions = subject.
          whitelist("MIT").
          unwhitelist("MIT")
        expect(decisions).not_to be_whitelisted(License.find_by_name("MIT"))
      end

      it "is cumulative" do
        decisions = subject.
          whitelist("MIT").
          unwhitelist("MIT").
          whitelist("MIT")
        expect(decisions).to be_whitelisted(License.find_by_name("MIT"))
      end

      it "adapts names" do
        decisions = subject.
          whitelist("MIT").
          unwhitelist("Expat")
        expect(decisions).not_to be_whitelisted(License.find_by_name("MIT"))
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

    describe ".name_project" do
      it "reports project name" do
        decisions = subject.name_project("proj")
        expect(decisions.project_name).to eq "proj"
      end
    end

    describe ".unname_project" do
      it "reports project name" do
        decisions = subject.
          name_project("proj").
          unname_project
        expect(decisions.project_name).to be_nil
      end
    end

    describe "persistence" do
      def roundtrip(decisions)
        described_class.restore(decisions.persist)
      end

      it "can restore added packages" do
        decisions = roundtrip(
          subject.
          add_package("dep", "0.2.0")
        )
        packages = decisions.packages
        expect(packages.map(&:name)).to eq ["dep"]
      end

      it "can restore removed packages" do
        decisions = roundtrip(
          subject.
          add_package("dep", nil).
          remove_package("dep")
        )
        expect(decisions.packages.size).to eq 0
      end

      it "can restore licenses" do
        license = roundtrip(
          subject.license("dep", "MIT")
        ).licenses_of("dep").first
        expect(license).to eq License.find_by_name("MIT")
      end

      it "can restore unlicenses" do
        licenses = roundtrip(
          subject.
          license("dep", "MIT").
          license("dep", "GPL").
          unlicense("dep", "MIT")
        ).licenses_of("dep")
        expect(licenses).to eq [License.find_by_name("GPL")].to_set
      end

      it "can restore approvals" do
        time = Time.now.getutc
        decisions = roundtrip(subject.approve("dep", who: "Somebody", why: "Some reason", when: time))
        expect(decisions).to be_approved("dep")
        approval = decisions.approval_of("dep")
        expect(approval.who).to eq "Somebody"
        expect(approval.why).to eq "Some reason"
        expect(approval.safe_when).to eq time
      end

      it "can restore unapprovals" do
        decisions = roundtrip(
          subject.
          approve("dep").
          unapprove("dep")
        )
        expect(decisions).not_to be_approved("dep")
      end

      it "can restore whitelists" do
        decisions = roundtrip(
          subject.whitelist("MIT")
        )
        expect(decisions).to be_whitelisted(License.find_by_name("MIT"))
      end

      it "can restore un-whitelists" do
        decisions = roundtrip(
          subject.
          whitelist("MIT").
          unwhitelist("MIT")
        )
        expect(decisions).not_to be_whitelisted(License.find_by_name("MIT"))
      end

      it "can restore ignorals" do
        decisions = roundtrip(subject.ignore("dep"))
        expect(decisions).to be_ignored("dep")
      end

      it "can restore heeds" do
        decisions = roundtrip(
          subject.
          ignore("dep").
          heed("dep")
        )
        expect(decisions).not_to be_ignored("dep")
      end

      it "can restore ignored groups" do
        decisions = roundtrip(
          subject.
          ignore_group("development")
        )
        expect(decisions).to be_ignored_group("development")
      end

      it "can restore heeded groups" do
        decisions = roundtrip(
          subject.
          ignore_group("development").
          heed_group("development")
        )
        expect(decisions).not_to be_ignored_group("development")
      end

      it "can restore project names" do
        decisions = roundtrip(
          subject.
          name_project("an-app")
        )
        expect(decisions.project_name).to eq "an-app"
      end

      it "can restore project unnames" do
        decisions = roundtrip(
          subject.
          name_project("an-app").
          unname_project
        )
        expect(decisions.project_name).to be_nil
      end
    end
  end
end
