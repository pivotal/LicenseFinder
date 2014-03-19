require 'spec_helper'

module LicenseFinder
  describe Dependency do
    describe '.unapproved' do
      let(:config) { Configuration.new('whitelist' => ['MIT', 'other']) }

      before do
        LicenseFinder.stub(:config).and_return config
      end

      it "should return all unapproved dependencies" do
        dependency = Dependency.create(name: "unapproved dependency", version: '0.0.1', 'license_name' => 'other')
        approved = Dependency.create(name: "approved dependency", version: '0.0.1', 'license_name' => 'other')
        approved.manually_approved = true
        approved.save
        whitelisted = Dependency.create(name: "approved dependency", version: '0.0.1', 'license_name' => License.find_by_name('MIT'))
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
    end

    describe '#approve!' do
      it "should update the database to show the dependency is approved" do
        dependency = Dependency.create(name: "foo", version: '0.0.1')
        dependency.approve!
        dependency.reload.should be_approved
      end
    end

    describe "#approved?" do
      let(:not_manually_approved) { Dependency.create(name: 'some gem', manually_approved: false).reload }
      let(:manually_approved) { Dependency.create(name: 'some gem', manually_approved: true).reload }

      it "is true if its license is whitelisted" do
        not_manually_approved.stub_chain(:license, whitelisted?: true)
        not_manually_approved.should be_approved
      end

      it "is true if it has been approved" do
        manually_approved.stub_chain(:license, whitelisted?: false)
        manually_approved.should be_approved
      end

      it "is false otherwise" do
        not_manually_approved.stub_chain(:license, whitelisted?: false)
        not_manually_approved.should_not be_approved
      end
    end

    describe "#set_license_manually!" do
      let(:dependency) { Dependency.create(name: 'foogem') }

      it "sets manual license to true" do
        dependency.license_manual.should be_false
        dependency.set_license_manually!('Updated')
        dependency.license_manual.should be_true
      end

      it "modifies the license" do
        dependency.set_license_manually!('Updated')
        dependency.reload.license.name.should == 'Updated'
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
        dependency.set_license_manually!("manual")
        dependency.apply_better_license "new"
        dependency.license.name.should == "manual"
      end

      it "saves a new license" do
        dependency.apply_better_license "new license"
        dependency.license.name.should == "new license"
      end

      it "updates the license's name" do
        dependency.license = License.find_by_name("old")

        dependency.apply_better_license "new license"
        dependency.license.name.should == "new license"
      end

      it "does not change the approval" do
        dependency.license = License.find_by_name("old")
        dependency.manually_approved = true

        dependency.apply_better_license "new license"
        dependency.should be_approved
      end
    end
  end
end

