require 'spec_helper'

module LicenseFinder
  describe Dependency do
    let(:attributes) do
      {
        'name' => "spec_name",
        'version' => "2.1.3",
        'license' => "GPLv2",
        'approved' => false,
        'notes' => 'some notes',
        'homepage' => 'homepage',
        'license_files' => ['/Users/pivotal/foo/lic1', '/Users/pivotal/bar/lic2'],
        'bundler_groups' => ["test"]
      }
    end

    let(:config) { Configuration.new }

    before do
      LicenseFinder.stub(:config).and_return config
      config.whitelist = ["MIT", "other"]
    end

    describe ".create_non_bundler" do
      it "should add a Dependency" do
        expect do
          Dependency.create_non_bundler("MIT", "js_dep", "0.0.0")
        end.to change(Dependency, :count).by(1)
      end

      it "should mark the dependency as manual" do
        Dependency.create_non_bundler("MIT", "js_dep", "0.0.0")
          .should be_manual
      end

      it "should set the appropriate values" do
        dep = Dependency.create_non_bundler("GPL", "js_dep", "0.0.0")
        dep.name.should == "js_dep"
        dep.version.should == "0.0.0"
        dep.license.name.should == "GPL"
        dep.should_not be_approved
      end

      it "should complain if the dependency already exists" do
        Dependency.create(name: "current dependency 1")
        expect { Dependency.create_non_bundler("GPL", "current dependency 1", "0.0.0") }
          .to raise_error(LicenseFinder::Error)
      end
    end

    describe ".destroy_non_bundler" do
      it "should remove a non bundler Dependency" do
        Dependency.create_non_bundler("GPL", "a non-bundler dep", nil)
        expect do
          Dependency.destroy_non_bundler("a non-bundler dep")
        end.to change(Dependency, :count).by(-1)
      end

      it "should not remove a bundler Dependency" do
        Dependency.create(name: "a bundler dep")
        expect do
          expect do
            Dependency.destroy_non_bundler("a bundler dep")
          end.to raise_error(LicenseFinder::Error)
        end.to_not change(Dependency, :count)
      end
    end

    describe ".destroy_obsolete" do
      it "destroys every dependency except for the ones provided as 'current' or marked as 'manual'" do
        cur1 = Dependency.create(name: "current dependency 1")
        cur2 = Dependency.create(name: "current dependency 2")
        man1 = Dependency.create(name: "manual dependency", manual: true)
        Dependency.create(name: "old dependency 1")
        Dependency.create(name: "old dependency 2")

        Dependency.destroy_obsolete([cur1, cur2])
        Dependency.all.map(&:name).should =~ [cur1, cur2, man1].map(&:name)
      end
    end

    describe '.unapproved' do
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
        described_class.named("referenced_again").approval.should be
        described_class.named("referenced_again").approval.should be
      end

      it "attaches an approval to a dependency that is currently missing one" do
        Dependency.create(name: "foo")
        described_class.named("foo").approval.should be
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
      end

      it "is false otherwise" do
        dependency.stub_chain(:license, whitelisted?: false)
        dependency.stub_chain(:approval, state: false)
        dependency.should_not be_approved
      end
    end

    describe "#set_license_manually" do
      let(:gem) do
        dependency = Dependency.new(name: "bob", version: '0.0.1')
        dependency.license = LicenseAlias.create(name: 'Original')
        dependency.save
        dependency
      end

      it "delegates to the license" do
        gem.license.should_receive(:set_manually).with('Updated')
        gem.set_license_manually('Updated')
      end
    end
  end
end

