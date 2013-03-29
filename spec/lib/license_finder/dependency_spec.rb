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

    describe '#license_url' do
      it "should delegate to LicenseUrl.find_by_name" do
        LicenseFinder::LicenseUrl.stub(:find_by_name).with("MIT").and_return "http://license-url.com"
        Dependency.new('license' => "MIT").license_url.should == "http://license-url.com"
      end
    end

    describe '#merge' do
      subject do
        Dependency.new(
          'name' => 'foo',
          'license' => 'MIT',
          'version' => '0.0.1',
          'license_files' => "old license files"
        )
      end

      let(:new_dep) do
        Dependency.new(
          'name' => 'foo',
          'license' => 'MIT',
          'version' => '0.0.2',
          'license_files' => "new license files",
          'summary' => 'foo summary',
          'description' => 'awesome foo description!',
          'bundler_groups' => [1, 2, 3],
          'homepage' => "http://new.homepage"
        )
      end

      it 'should raise an error if the names do not match' do
        new_dep.name = 'bar'

        expect {
          subject.merge(new_dep)
        }.to raise_error
      end

      it 'should return the new version, license files, source, and homepage' do
        merged = subject.merge(new_dep)

        merged.version.should == '0.0.2'
        merged.license_files.should == new_dep.license_files
        merged.homepage.should == new_dep.homepage
      end

      it 'should return the new summary and description and bundle groups' do
        merged = subject.merge new_dep

        merged.summary.should == new_dep.summary
        merged.description.should == new_dep.description
        merged.bundler_groups.should == new_dep.bundler_groups
      end

      it 'should return the old notes' do
        subject.notes = 'old notes'
        new_dep.notes = 'new notes'

        merged = subject.merge(new_dep)

        merged.notes.should == 'old notes'
      end

      context "license changes to something other than 'other'" do
        before { new_dep.license = 'new license' }

        context "new license is whitelisted" do
          before { LicenseFinder.config.stub(:whitelist).and_return [new_dep.license] }

          it "should set the approval to true" do
            merged = subject.merge new_dep
            merged.should be_approved
          end
        end

        context "new license is not whitelisted" do
          it "should set the approval to false" do
            merged = subject.merge new_dep
            merged.should_not be_approved
          end
        end
      end

      context "license changes to unknown (i.e., 'other')" do
        before { new_dep.license = 'other' }

        it "should not change the license" do
          merged = subject.merge new_dep
          merged.license.should == 'MIT'
        end

        it "should not change the approval" do
          approved = subject.approved?
          merged = subject.merge new_dep
          merged.approved?.should == approved
        end
      end

      context "license does not change" do
        before { new_dep.license.should == subject.license }

        it "should not change the license or approval" do
          existing_license = subject.license
          existing_approval = subject.approved?
          merged = subject.merge new_dep
          merged.approved?.should == existing_approval
          merged.license.should == existing_license
        end
      end
    end

    describe '.unapproved' do
      it "should return all unapproved dependencies" do
        Dependency.delete_all
        Dependency.new('name' => "unapproved dependency", 'version' => '0.0.1', 'approved' => false).save
        Dependency.new('name' => "approved dependency", 'version' => '0.0.1', 'approved' => true).save

        unapproved = Dependency.unapproved
        unapproved.count.should == 1
        unapproved.should_not be_any(&:approved?)
      end
    end

    describe '#approve!' do
      it "should update the yaml file to show the gem is approved" do
        gem = Dependency.new('name' => "foo", 'version' => '0.0.1')
        gem.approve!
        reloaded_gem = Dependency.find_by_name(gem.name)
        reloaded_gem.approved.should be_true
      end
    end

    describe "#approved" do
      it "should return true when the license is whitelisted" do
        dependency = Dependency.new('license' => 'MIT')
        dependency.should be_approved
      end

      it "should return true when the license is an alternative name of a whitelisted license" do
        dependency = Dependency.new('license' => 'Expat')
        dependency.should be_approved
      end

      it "should return true when the license has no matching license class, but is whitelisted anyways" do
        dependency = Dependency.new('license' => 'other')
        dependency.should be_approved
      end

      it "should return false when the license is not whitelisted" do
        dependency = Dependency.new('license' => 'GPL')
        dependency.should_not be_approved
      end

      it "should be overridable" do
        dependency = Dependency.new
        dependency.approved = true
        dependency.should be_approved
      end
    end

    describe "defaults" do
      %w(license_files bundler_groups children parents).each do |attribute|
        describe "##{attribute}" do
          it "should default to an empty array" do
            Dependency.new.send(attribute).should == []
          end
        end
      end
    end

    describe "#set_license_manually" do
      let(:gem) { Dependency.new('name' => "foo", 'version' => '0.0.1', 'license' => 'Original') }

      it "modifies the license" do
        gem.license.should == 'Original'
        gem.set_license_manually('Updated')
        reloaded_gem = Dependency.find_by_name(gem.name)
        reloaded_gem.license.should == 'Updated'
      end

      it "marks the approval as manual" do
        gem.set_license_manually('Updated')
        reloaded_gem = Dependency.find_by_name(gem.name)
        reloaded_gem.manual.should be_true
      end
    end
  end
end

