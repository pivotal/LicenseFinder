require 'spec_helper'

describe LicenseFinder::BundledGem do
  subject { LicenseFinder::BundledGem.new(gemspec) }

  let(:gemspec) do
    Gem::Specification.new do |s|
      s.name = 'spec_name'
      s.version = '2.1.3'
      s.summary = 'summary'
      s.description = 'description'
      s.homepage = 'homepage'

      s.add_dependency 'foo'
    end
  end

  def fixture_path(fixture)
    Pathname.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec', 'fixtures', fixture)).realpath.to_s
  end

  its(:name) { should == 'spec_name 2.1.3' }
  its(:dependency_name) { should == 'spec_name' }
  its(:dependency_version) { should == '2.1.3' }
  its(:install_path) { should == gemspec.full_gem_path }

  describe "#determine_license" do
    subject do
      details = LicenseFinder::BundledGem.new(gemspec)
      details.stub(:license_files).and_return([license_file])
      details
    end

    let(:license_file) { LicenseFinder::PossibleLicenseFile.new('gem', 'gem/license/path') }

    it "returns the license from the gemspec if provided" do
      gemspec.stub(:license).and_return('Some License')

      subject.determine_license.should == "Some License"
    end

    it "returns the matched license if detected" do
      license_file.stub(:license).and_return('Detected License')

      subject.determine_license.should == "Detected License"
    end

    it "returns 'other' otherwise" do
      license_file.stub(:license).and_return(nil)

      subject.determine_license.should == "other"
    end
  end

  describe "#license_files" do
    it "is empty if there aren't any license files" do
      subject.license_files.should == []
    end

    it "includes files with names like LICENSE, License or COPYING" do
      gemspec.stub(:full_gem_path).and_return(fixture_path('license_names'))

      subject.license_files.map(&:file_name).should =~
        %w[COPYING.txt LICENSE Mit-License README.rdoc Licence.rdoc]
    end

    it "includes files deep in the hierarchy" do
      gemspec.stub(:full_gem_path).and_return(fixture_path('nested_gem'))

      subject.license_files.map { |f| [f.file_name, f.file_path] }.should =~ [
        %w[LICENSE vendor/LICENSE]
      ]
    end

    it "includes both files nested inside LICENSE directory and top level files" do
      gemspec.stub(:full_gem_path).and_return(fixture_path('license_directory'))
      found_license_files = subject.license_files

      found_license_files.map { |f| [f.file_name, f.file_path] }.should =~ [
        %w[BSD-2-Clause.txt LICENSE/BSD-2-Clause.txt],
        %w[GPL-2.0.txt LICENSE/GPL-2.0.txt],
        %w[MIT.txt LICENSE/MIT.txt],
        %w[RUBY.txt LICENSE/RUBY.txt],
        %w[COPYING COPYING],
        %w[LICENSE LICENSE/LICENSE]
      ]
    end

    it "handles non UTF8 encodings" do
      gemspec.stub(:full_gem_path).and_return(fixture_path('utf8_gem'))
      expect { subject.license_files }.not_to raise_error
    end
  end

  describe "#save_or_merge" do
    let(:bundled_gem) { LicenseFinder::BundledGem.new(gemspec) }
    subject { bundled_gem.save_or_merge }

    context "when the dependency is new" do
      it "persists gem data" do
        subject.id.should be
        subject.name.should == "spec_name"
        subject.version.should == "2.1.3"
        subject.summary.should == "summary"
        subject.description.should == "description"
        subject.homepage.should == "homepage"
      end

      it "associates children" do
        subject.children.map(&:name).should == ['foo']
      end

      it "marks depenency as unapproved by default" do
        subject.approval.state.should == nil
      end

      context "with a bundler dependency" do
        let(:bundled_gem) { LicenseFinder::BundledGem.new(gemspec, stub(:bundler_dependency, groups: %w[1 2 3]))}

        it "saves the bundler groups" do
          subject.bundler_groups.map(&:name).should =~ %w[1 2 3]
        end
      end
    end

    context "when the dependency already existed" do
      let!(:old_copy) do
        LicenseFinder::Dependency.create(
          name: 'spec_name',
          version: '0.1.2',
          summary: 'old summary',
          description: 'old desription',
          homepage: 'old homepage'
        )
      end

      it "merges in the latest data" do
        subject.id.should == old_copy.id
        subject.name.should == old_copy.name
        subject.version.should == "2.1.3"
        subject.summary.should == "summary"
        subject.description.should == "description"
        subject.homepage.should == "homepage"
      end

      it "keeps a manually assigned license" do
        old_copy.license = LicenseFinder::Dependency::License.create(name: 'foo', manual: true)
        old_copy.save
        subject.license.name.should == 'foo'
      end

      it "keeps approval" do
        old_copy.approval = LicenseFinder::Dependency::Approval.create(state: true)
        old_copy.save
        subject.approval.state.should == true
      end

      it "ensures correct children are associated" do
        old_copy.add_child LicenseFinder::Dependency.new(name: 'bob')
        old_copy.add_child LicenseFinder::Dependency.new(name: 'joe')
        old_copy.children.each(&:save)
        subject.children.map(&:name).should =~ ['foo']
      end

      context "with a bundler dependency" do
        let(:bundled_gem) { LicenseFinder::BundledGem.new(gemspec, stub(:bundler_dependency, groups: %w[1 2 3]))}

        before do
          old_copy.add_bundler_group LicenseFinder::Dependency::BundlerGroup.find_or_create(name: 'a')
          old_copy.add_bundler_group LicenseFinder::Dependency::BundlerGroup.find_or_create(name: 'b')
        end

        it "ensures the correct bundler groups are associated" do
          subject.bundler_groups.map(&:name).should =~ %w[1 2 3]
        end
      end

      context "license changes to something other than 'other'" do
        before do
          old_copy.license = LicenseFinder::Dependency::License.create(name: 'other')
          old_copy.save
          gemspec.license = "new license"
        end

        context "new license is whitelisted" do
          before { LicenseFinder.config.stub(:whitelist).and_return [gemspec.license] }

          it "should set the approval to true" do
            subject.should be_approved
          end
        end

        context "new license is not whitelisted" do
          it "should set the approval to false" do
            subject.should_not be_approved
          end
        end
      end

      context "license changes to unknown (i.e., 'other')" do
        before do
          old_copy.license = LicenseFinder::Dependency::License.create(name: 'MIT')
          old_copy.approval = LicenseFinder::Dependency::Approval.create(state: false)
          old_copy.save
          gemspec.license = "other"
        end

        it "should not change the license" do
          subject.license.name.should == 'MIT'
        end

        it "should not change the approval" do
          subject.should_not be_approved
        end
      end

      context "license does not change" do
        before do
          old_copy.license = LicenseFinder::Dependency::License.create(name: 'MIT')
          old_copy.approval = LicenseFinder::Dependency::Approval.create(state: false)
          old_copy.save
          gemspec.license = "MIT"
        end

        it "should not change the license or approval" do
          subject.should_not be_approved
          subject.license.name.should == "MIT"
        end
      end
    end
  end
end
