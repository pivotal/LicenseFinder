require 'spec_helper'

module LicenseFinder
  describe Dependency do
    describe '.unapproved' do
      before do
        allow(License.find_by_name('MIT')).to receive_messages(:whitelisted? =>  true)
        allow(LicenseFinder.config).to receive(:ignore_dependencies) { ['this ignored dependency', 'that ignored dependency'] }
      end

      it "should return all unapproved dependencies that are not ignored" do
        dependency = Dependency.create(name: "unapproved dependency", version: '0.0.1')
        approved = Dependency.create(name: "approved dependency", version: '0.0.1')
        this_ignored = Dependency.create(name: "this ignored dependency", version: '0.0.1')
        that_ignored = Dependency.create(name: "that ignored dependency", version: '0.0.1')
        approved.approve!
        whitelisted = Dependency.create(name: "approved dependency", version: '0.0.1')
        whitelisted.licenses = [License.find_by_name('MIT')]
        whitelisted.save

        unapproved = Dependency.unapproved
        expect(unapproved.count).to eq(1)
        expect(unapproved).not_to be_any(&:approved?)
      end
    end

    describe ".named" do
      it "creates a new dependency" do
        dep = described_class.named("never_seen")
        expect(dep.name).to eq("never_seen")
        expect(dep).not_to be_new
      end

      it "returns an existing dependency" do
        described_class.named("referenced_again")
        dep = described_class.named("referenced_again")
        expect(dep.name).to eq("referenced_again")
        expect(dep).not_to be_new
        expect(Dependency.count(name: "referenced_again")).to eq(1)
      end
    end

    describe ".acknowledged" do
      it "returns all dependencies that are not ignored" do
        acknowledged_dependency = Dependency.create(name: "acknowledged dependency", version: '0.0.1')
        ignored_dependency = Dependency.create(name: "ignored dependency", version: '0.0.1')
        allow(LicenseFinder.config).to receive(:ignore_dependencies) { [ignored_dependency.name] }

        expect(Dependency.acknowledged).to match_array [acknowledged_dependency]
      end
    end

    describe '#approve!' do
      it "should update the database to show the dependency is approved" do
        dependency = Dependency.named("foo")
        dependency.approve!
        expect(dependency.reload).to be_approved
      end

      it "should record the approver and notes" do
        dependency = Dependency.named("foo")
        dependency.approve!("Julian", "We really need this")
        approval = dependency.reload.manual_approval
        expect(approval.approver).to eq "Julian"
        expect(approval.notes).to eq "We really need this"
      end
    end

    describe "#approved?" do
      let(:not_approved_manually) { Dependency.create(name: 'some gem').reload }
      let(:approved_manually) { Dependency.create(name: 'some gem').approve!.reload }

      it "is true if its license is whitelisted" do
        fake_license = double(:license, whitelisted?: true)
        allow(not_approved_manually).to receive(:licenses).and_return [fake_license]
        expect(not_approved_manually).to be_approved
      end

      it "is true if one of its licenses is whitelisted" do
        fake_licenses = [double(:license, whitelisted?: false), double(:license, whitelisted?: true)]
        allow(not_approved_manually).to receive(:licenses).and_return fake_licenses
        expect(not_approved_manually).to be_approved
      end

      it "is true if it has been approved" do
        allow(approved_manually).to receive_message_chain(:license, whitelisted?: false)
        expect(approved_manually).to be_approved
      end

      it "is false otherwise" do
        allow(not_approved_manually).to receive_message_chain(:license, whitelisted?: false)
        expect(not_approved_manually).not_to be_approved
      end
    end

    describe "#set_license_manually!" do
      let(:dependency) { Dependency.create(name: 'foogem') }

      it "sets manual license to true" do
        expect(dependency).not_to be_license_assigned_manually
        dependency.set_license_manually! License.find_by_name("Updated")
        expect(dependency).to be_license_assigned_manually
      end

      it "modifies the license" do
        dependency.set_license_manually! License.find_by_name("Updated")
        expect(dependency.reload.licenses.first.name).to eq('Updated')
      end
    end

    describe "#bundler_group_names=" do
      let(:dependency) { Dependency.named('some gem') }

      it "saves the bundler groups" do
        dependency.bundler_group_names = %w[1 2 3]
        expect(dependency.bundler_groups.map(&:name)).to match_array(%w[1 2 3])
      end

      it "removed outdated groups and adds new groups" do
        dependency.add_bundler_group BundlerGroup.named('old')
        dependency.add_bundler_group BundlerGroup.named('maintained')
        dependency.bundler_group_names = %w[new maintained]
        expect(dependency.bundler_groups.map(&:name)).to match_array(%w[new maintained])
      end
    end

    describe "children_names=" do
      let(:dependency) { Dependency.named('some gem') }

      it "saves the children" do
        dependency.children_names = %w[1 2 3]
        expect(dependency.children.map(&:name)).to match_array(%w[1 2 3])
      end

      it "removes outdated children and adds new children" do
        dependency.add_child Dependency.named('old')
        dependency.add_child Dependency.named('maintained')
        dependency.children_names = %w[new maintained]
        expect(dependency.children.map(&:name)).to match_array(%w[new maintained])
      end
    end

    describe "#set_licenses" do
      let(:dependency) { Dependency.named('some gem') }

      it "keeps a manually assigned license" do
        dependency.set_license_manually! License.find_by_name("manual")
        dependency.set_licenses [License.find_by_name("new")]
        expect(dependency.licenses.first.name).to eq "manual"
      end

      it "saves a new license" do
        dependency.set_licenses [License.find_by_name("new license")]
        expect(dependency.licenses.first.name).to eq "new license"
      end

      it "updates the license's name" do
        dependency.licenses = [License.find_by_name("old")]

        dependency.set_licenses [License.find_by_name("new license")]
        expect(dependency.licenses.first.name).to eq "new license"
      end

      it "won't update the database if the license isn't changing" do
        # See note in PackageSaver#save
        dependency.licenses = [License.find_by_name("same")]
        expect(dependency).to be_modified
        dependency.save
        expect(dependency).not_to be_modified

        dependency.set_licenses [License.find_by_name("same")]
        expect(dependency).not_to be_modified
      end

      it "updates the database if an additional license is added" do
        # See note in PackageSaver#save
        dependency.licenses = [License.find_by_name("first")]
        expect(dependency).to be_modified
        dependency.save
        expect(dependency).not_to be_modified

        dependency.set_licenses [License.find_by_name("first"), License.find_by_name("second")]
        expect(dependency).to be_modified
      end

      it "does not change the approval" do
        dependency.licenses = [License.find_by_name("old")]
        dependency.approve!

        dependency.set_licenses [License.find_by_name("new license")]
        expect(dependency).to be_approved
      end
    end
  end
end

