require 'spec_helper'

module LicenseFinder
  describe Dependency do
    describe '.unapproved' do
      let(:config) { Configuration.new }

      before do
        LicenseFinder.stub(:config).and_return config
        config.whitelist = ["MIT", "other"]
      end

      it "should return all unapproved dependencies" do
        dependency = Dependency.create(name: "unapproved dependency", version: '0.0.1')
        dependency.approval = Approval.create(state: false)
        dependency.save
        approved = Dependency.create(name: "approved dependency", version: '0.0.1')
        approved.approval = Approval.create(state: true)
        approved.save
        whitelisted = Dependency.create(name: "approved dependency", version: '0.0.1')
        whitelisted.license = LicenseAlias.create(name: 'MIT')
        whitelisted.approval = Approval.create(state: false)
        whitelisted.save

        unapproved = Dependency.unapproved
        unapproved.count.should == 1
        unapproved.should_not be_any(&:approved?)
      end
    end

    describe ".named" do
      it "creates a new dependency" do
        dep = described_class.named("never_seen")
        dep.name.should == "never_seen"
        dep.should_not be_new
      end

      it "returns an existing dependency" do
        described_class.named("referenced_again")
        dep = described_class.named("referenced_again")
        dep.name.should == "referenced_again"
        dep.should_not be_new
        Dependency.count(name: "referenced_again").should == 1
      end

      it "always attaches an approval" do
        described_class.named("referenced_again").reload.approval.should be
        described_class.named("referenced_again").reload.approval.should be
      end

      it "attaches an approval to a dependency that is currently missing one" do
        Dependency.create(name: "foo")
        described_class.named("foo").reload.approval.should be
      end
    end

    describe '#approve!' do
      it "should update the database to show the dependency is approved" do
        dependency = Dependency.create(name: "foo", version: '0.0.1')
        dependency.approval = Approval.create(state: false)
        dependency.save
        dependency.approve!
        dependency.reload.should be_approved
      end
    end

    describe "#approved?" do
      let(:dependency) { Dependency.create(name: 'some gem') }

      it "is true if its license is whitelisted" do
        dependency.stub_chain(:license, whitelisted?: true)
        dependency.should be_approved
      end

      it "is true if it has been approved" do
        dependency.stub_chain(:license, whitelisted?: false)
        dependency.stub_chain(:approval, state: true)
        dependency.should be_approved

        dependency.stub_chain(:approval, state: 1) # jruby
        dependency.should be_approved
      end

      it "is false otherwise" do
        dependency.stub_chain(:license, whitelisted?: false)
        dependency.stub_chain(:approval, state: false)
        dependency.should_not be_approved

        dependency.stub_chain(:approval, state: 0) # jruby
        dependency.should_not be_approved
      end
    end

    describe "#set_license_manually!" do
      let(:license) { LicenseAlias.create(name: 'foolicense') }
      let(:dependency) { Dependency.create(name: 'foogem') }

      it "sets manual license to true" do
        dependency.license_manual.should be_false
        dependency.set_license_manually!('Updated')
        dependency.license_manual.should be_true
      end

      it "modifies the license" do
        LicenseAlias.should_receive(:named).with('Updated').and_return(license)
        dependency.set_license_manually!('Updated')
        dependency.reload.license.should == license
      end
    end

    describe "#bundler_group_names=" do
      let(:dependency) { Dependency.named('some gem') }

      it "saves the bundler groups" do
        dependency.bundler_group_names = %w[1 2 3]
        dependency.bundler_groups.map(&:name).should =~ %w[1 2 3]
      end

      it "removed outdated groups and adds new groups" do
        dependency.add_bundler_group BundlerGroup.named('old')
        dependency.add_bundler_group BundlerGroup.named('maintained')
        dependency.bundler_group_names = %w[new maintained]
        dependency.bundler_groups.map(&:name).should =~ %w[new maintained]
      end
    end

    describe "children_names=" do
      let(:dependency) { Dependency.named('some gem') }

      it "saves the children" do
        dependency.children_names = %w[1 2 3]
        dependency.children.map(&:name).should =~ %w[1 2 3]
      end

      it "removes outdated children and adds new children" do
        dependency.add_child Dependency.named('old')
        dependency.add_child Dependency.named('maintained')
        dependency.children_names = %w[new maintained]
        dependency.children.map(&:name).should =~ %w[new maintained]
      end
    end

    describe "#apply_better_license" do
      let(:dependency) { Dependency.named('some gem') }

      it "keeps a manually assigned license" do
        dependency.license = LicenseAlias.named("manual")
        dependency.license_manual = true

        dependency.apply_better_license "new"
        dependency.license.name.should == "manual"
      end

      it "saves a new license" do
        dependency.apply_better_license "new license"
        dependency.license.name.should == "new license"
      end

      it "re-uses an existing, unassociated, license alias" do
        dependency.license = LicenseAlias.named("old")

        new_license = LicenseAlias.named("new license")

        dependency.apply_better_license "new license"
        dependency.license.should == new_license
      end

      it "updates the license's name" do
        dependency.license = LicenseAlias.named("old")

        dependency.apply_better_license "new license"
        dependency.license.name.should == "new license"
      end

      it "does not change the approval" do
        dependency.license = LicenseAlias.named("old")
        dependency.approval = Approval.create(state: true)

        dependency.apply_better_license "new license"
        dependency.should be_approved
      end
    end
  end
end

