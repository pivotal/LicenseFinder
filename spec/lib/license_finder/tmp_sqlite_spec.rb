require "spec_helper"

describe LicenseFinder::Persistence::Dependency do
  let(:klass) { described_class }

  let(:attributes) do
    {
      'name' => "spec_name",
      'version' => "2.1.3",
      'summary' => "some summary",
      'description' => "some description",
      'license' => "GPLv2",
      'approved' => false,
      'notes' => 'some notes',
      'homepage' => 'www.homepage.com',
      'license_files' => ['/Users/pivotal/foo/lic1', '/Users/pivotal/bar/lic2'],
      'bundler_groups' => ["test"]
    }
  end

  before do
    klass.delete_all
  end

  describe '#save' do
    it "should persist all of the dependency's attributes" do
      dep = klass.new(attributes)
      dep.save

      LicenseFinder::Persistence::Sqlite::Dependency.count.should == 1
      saved_dep = LicenseFinder::Persistence::Sqlite::Dependency.first
      saved_dep.name.should == "spec_name"
      saved_dep.version.should == "2.1.3"
      saved_dep.summary.should == "some summary"
      saved_dep.description.should == "some description"
      saved_dep.homepage.should == "www.homepage.com"
    end
  end
end
