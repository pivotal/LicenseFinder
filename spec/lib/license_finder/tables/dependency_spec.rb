require 'spec_helper'

module LicenseFinder
  describe Dependency do
    describe '.unapproved' do
      before do
        License.find_by_name('MIT').stub(:whitelisted? =>  true)
      end

      it "should return all unapproved dependencies" do
        dependency = Dependency.create(name: "unapproved dependency", version: '0.0.1')
        approved = Dependency.create(name: "approved dependency", version: '0.0.1')
        approved.approve!
        whitelisted = Dependency.create(name: "approved dependency", version: '0.0.1')
        whitelisted.license = License.find_by_name('MIT')
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
        dependency = Dependency.named("foo")
        dependency.approve!
        dependency.reload.should be_approved
      end

      it "should record the approver and notes" do
        dependency = Dependency.named("foo")
        dependency.approve!("Julian", "We really need this")
        approval = dependency.reload.manual_approval
        approval.approver.should eq "Julian"
        approval.notes.should eq "We really need this"
      end
    end

    describe "#approved?" do
      let(:not_approved_manually) { Dependency.create(name: 'some gem').reload }
      let(:approved_manually) { Dependency.create(name: 'some gem').approve!.reload }

      it "is true if its license is whitelisted" do
        not_approved_manually.stub_chain(:license, whitelisted?: true)
        not_approved_manually.should be_approved
      end

      it "is true if it has been approved" do
        approved_manually.stub_chain(:license, whitelisted?: false)
        approved_manually.should be_approved
      end

      it "is false otherwise" do
        not_approved_manually.stub_chain(:license, whitelisted?: false)
        not_approved_manually.should_not be_approved
      end
    end

    describe "#set_license_manually!" do
      let(:dependency) { Dependency.create(name: 'foogem') }

      it "sets manual license to true" do
        dependency.should_not be_license_assigned_manually
        dependency.set_license_manually! License.find_by_name("Updated")
        dependency.should be_license_assigned_manually
      end

      it "modifies the license" do
        dependency.set_license_manually! License.find_by_name("Updated")
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
        dependency.set_license_manually! License.find_by_name("manual")
        dependency.apply_better_license License.find_by_name("new")
        dependency.license.name.should == "manual"
      end

      it "saves a new license" do
        dependency.apply_better_license License.find_by_name("new license")
        dependency.license.name.should == "new license"
      end

      it "updates the license's name" do
        dependency.license = License.find_by_name("old")

        dependency.apply_better_license License.find_by_name("new license")
        dependency.license.name.should == "new license"
      end

      it "won't update the database if the license isn't changing" do
        # See note in PackageSaver#save
        dependency.license = License.find_by_name("same")
        dependency.should be_modified
        dependency.save
        dependency.should_not be_modified

        dependency.apply_better_license License.find_by_name("same")
        dependency.should_not be_modified
      end

      it "does not change the approval" do
        dependency.license = License.find_by_name("old")
        dependency.approve!

        dependency.apply_better_license License.find_by_name("new license")
        dependency.should be_approved
      end
    end
  end
end

