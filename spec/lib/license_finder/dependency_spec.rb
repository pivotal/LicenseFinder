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

    let(:config) { LicenseFinder::Configuration.new }

    before do
      LicenseFinder.stub(:config).and_return config
      config.whitelist = ["MIT", "other"]
    end

    describe ".destroy_obsolete" do
      it "destroys every dependency except for the ones provided as 'current'" do
        cur1 = Dependency.create(name: "current dependency 1")
        cur2 = Dependency.create(name: "current dependency 2")
        Dependency.create(name: "old dependency 1")
        Dependency.create(name: "old dependency 2")

        Dependency.destroy_obsolete([cur1, cur2])
        Dependency.all.should =~ [cur1, cur2]
      end
    end

    describe '.unapproved' do
      it "should return all unapproved dependencies" do
        dependency = Dependency.create(name: "unapproved dependency", version: '0.0.1')
        dependency.approval = LicenseFinder::Approval.create(state: false)
        dependency.save
        dependency2 = Dependency.create(name: "approved dependency", version: '0.0.1')
        dependency2.approval = LicenseFinder::Approval.create(state: true)
        dependency2.save

        unapproved = Dependency.unapproved
        unapproved.count.should == 1
        unapproved.should_not be_any(&:approved?)
      end
    end

    describe '#approve!' do
      it "should update the database to show the dependency is approved" do
        dependency = Dependency.create(name: "foo", version: '0.0.1')
        dependency.approval = LicenseFinder::Approval.create(state: false)
        dependency.save
        dependency.approve!
        dependency.reload.should be_approved
      end
    end

    describe "#approved" do
      let(:dependency) { Dependency.create(name: 'some gem') }

      it "should return true when the license is whitelisted" do
        dependency.license = LicenseFinder::LicenseAlias.create(name: 'MIT')
        dependency.save
        dependency.should be_approved
      end

      it "should return true when the license is an alternative name of a whitelisted license" do
        dependency.license = LicenseFinder::LicenseAlias.create(name: 'Expat')
        dependency.save
        dependency.should be_approved
      end

      it "should return true when the license has no matching license class, but is whitelisted anyways" do
        dependency.license = LicenseFinder::LicenseAlias.create(name: 'other')
        dependency.save
        dependency.should be_approved
      end

      it "should return false when the license is not whitelisted" do
        dependency.license = LicenseFinder::LicenseAlias.create(name: 'GPL')
        dependency.save
        dependency.should_not be_approved
      end
    end

    describe "#set_license_manually" do
      let(:gem) do
        dependency = Dependency.new(name: "bob", version: '0.0.1')
        dependency.license = LicenseFinder::LicenseAlias.create(name: 'Original')
        dependency.save
        dependency
      end

      it "modifies the license" do
        gem.license.name.should == 'Original'
        gem.set_license_manually('Updated')
        gem.reload.license.name.should == 'Updated'
      end

      it "marks the approval as manual" do
        gem.set_license_manually('Updated')
        gem.reload.license.manual.should be_true
      end
    end

    describe '#license_url' do
      it "should delegate to LicenseUrl.find_by_name" do
        LicenseFinder::LicenseUrl.stub(:find_by_name).with("MIT").and_return "http://license-url.com"
        license = LicenseFinder::LicenseAlias.new(name: 'MIT')
        license.url.should == "http://license-url.com"
      end
    end
  end
end

