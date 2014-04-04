require "spec_helper"

describe LicenseFinder::YmlToSql do
  let(:legacy_attributes) do
    {
      'name' => "spec_name",
      'version' => "2.1.3",
      'license' => "GPLv2",
      'license_url' => "www.license_url.org",
      'approved' => true,
      'summary' => "some summary",
      'description' => "some description",
      'homepage' => 'www.homepage.com',
      'children' => ["child1_name"],
      'parents' => ["parent1_name"],
      'bundler_groups' => [:test],
      'source' => source,

      'notes' => 'some notes',
      'license_files' => ['/Users/pivotal/foo/lic1', '/Users/pivotal/bar/lic2'],
    }
  end
  let(:source) { nil }

  describe ".needs_conversion?" do
    it "is true if the yml still exists" do
      yaml_file = double(:yaml_file, :exist? => true)
      LicenseFinder.config.artifacts.stub(legacy_yaml_file: yaml_file)

      described_class.needs_conversion?.should be_true
    end

    it "is false otherwise" do
      yaml_file = double(:yaml_file, :exist? => false)
      LicenseFinder.config.artifacts.stub(legacy_yaml_file: yaml_file)

      described_class.needs_conversion?.should be_false
    end
  end

  describe ".remove_yml" do
    it "removes the yml file" do
      yaml_file = double(:yaml_file)
      LicenseFinder.config.artifacts.stub(legacy_yaml_file: yaml_file)

      yaml_file.should_receive(:delete)
      described_class.remove_yml
    end
  end

  describe '.convert_all' do
    before do
      (LicenseFinder::DB.tables - [:schema_migrations]).each { |table| LicenseFinder::DB[table].truncate }
    end

    describe "when dependency source is set to bundle" do
      let(:source) { "bundle" }

      it "sets manual to be false" do
        described_class.convert_all([legacy_attributes])

        saved_dep = described_class::Sql::Dependency.first
        saved_dep.should_not be_added_manually
      end
    end

    describe "when dependency source is not set to bundle" do
      let(:source) { "" }

      it "sets manual to be true" do
        described_class.convert_all([legacy_attributes])

        saved_dep = described_class::Sql::Dependency.first
        saved_dep.should be_added_manually
      end
    end

    it "persists all of the dependency's attributes" do
      described_class.convert_all([legacy_attributes])

      described_class::Sql::Dependency.count.should == 1
      saved_dep = described_class::Sql::Dependency.first
      saved_dep.name.should == "spec_name"
      saved_dep.version.should == "2.1.3"
      saved_dep.summary.should == "some summary"
      saved_dep.description.should == "some description"
      saved_dep.homepage.should == "www.homepage.com"
      saved_dep.manual_approval.should be
    end

    it "associates the license to the dependency" do
      described_class.convert_all([legacy_attributes])

      saved_dep = described_class::Sql::Dependency.first
      saved_dep.license.name.should == "GPLv2"
      saved_dep.license.url.should == "http://www.gnu.org/licenses/gpl-2.0.txt"
    end

    it "associates bundler groups" do
      described_class.convert_all([legacy_attributes])

      saved_dep = described_class::Sql::Dependency.first
      saved_dep.bundler_groups.count.should == 1
      saved_dep.bundler_groups.first.name.should == 'test'
    end

    it "associates children" do
      child_attrs = {
        'name' => 'child1_name',
        'version' => '0.0.1',
        'license' => 'other'
      }
      described_class.convert_all([legacy_attributes, child_attrs])

      described_class::Sql::Dependency.count.should == 2
      saved_dep = described_class::Sql::Dependency.first(name: 'spec_name')
      saved_dep.children.count.should == 1
      saved_dep.children.first.name.should == 'child1_name'
    end
  end
end
