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
        'readme_files' => ['/Users/pivotal/foo/Readme1', '/Users/pivotal/bar/Readme2'],
        'source' => "bundle",
        'bundler_groups' => ["test"]
      }
    end

    before do
      LicenseFinder.stub(:config).and_return(double('config', {
        :whitelist => %w(MIT),
        :dependencies_yaml => 'dependencies.yml'
      }))
    end

    describe "#approved" do
      it "should return true when the license is whitelisted" do
        dependency = Dependency.new('license' => 'MIT')
        dependency.approved.should == true
      end

      it "should return false when the license is not whitelisted" do
        dependency = Dependency.new('license' => 'GPL')
        dependency.approved.should == false
      end

      it "should be overridable" do
        dependency = Dependency.new
        dependency.approved = true
        dependency.approved.should == true
      end
    end

    describe '#license_url' do
      it "should delegate to LicenseUrl.find_by_name" do
        LicenseFinder::LicenseUrl.stub(:find_by_name).with("MIT").and_return "http://license-url.com"
        Dependency.new(:license => "MIT").license_url.should == "http://license-url.com"
      end
    end

    describe '#merge' do
      subject do
        Dependency.new(
          'name' => 'foo',
          'license' => 'MIT',
          'version' => '0.0.1',
          'license_files' => "old license files",
          'readme_files' => "old readme files"
        )
      end

      let(:new_dep) do
        Dependency.new(
          'name' => 'foo',
          'license' => 'MIT',
          'version' => '0.0.2',
          'license_files' => "new license files",
          'readme_files' => "new readme files",
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

      it 'should return the new version, license files, readme files, source, and homepage' do
        merged = subject.merge(new_dep)

        merged.version.should == '0.0.2'
        merged.license_files.should == new_dep.license_files
        merged.readme_files.should == new_dep.readme_files
        merged.source.should == new_dep.source
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

      it 'should return the new license and approval if the license is different' do
        subject.license = "MIT"
        subject.approved = true

        new_dep.license = "GPLv2"
        new_dep.approved = false

        merged = subject.merge(new_dep)

        merged.license.should == "GPLv2"
        merged.approved.should == false
      end

      it 'should return the old license and approval if the new license is the same or "other"' do
        subject.approved = false
        subject.approved.should be_false
        new_dep.approved = true

        subject.merge(new_dep).approved.should == false

        new_dep.license = 'other'

        subject.merge(new_dep).approved.should == false
      end
    end

    describe '#approve!' do
      it "should update the yaml file to show the gem is approved" do
        gem = Dependency.new(name: "foo")
        gem.approve!
        reloaded_gem = Dependency.find_by_name(gem.name)
        reloaded_gem.approved.should be_true
      end
    end

    describe "defaults" do
      %w(license_files readme_files bundler_groups children parents).each do |attribute|
        describe "##{attribute}" do
          it "should default to an empty array" do
            Dependency.new.send(attribute).should == []
          end
        end
      end
    end
  end
end

