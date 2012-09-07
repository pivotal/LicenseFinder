require 'spec_helper'

describe LicenseFinder::Dependency do
  let(:attributes) do
    {
        'name' => "spec_name",
        'version' => "2.1.3",
        'license' => "GPL",
        'approved' => false,
        'license_url' => 'http://www.apache.org/licenses/LICENSE-2.0.html',
        'notes' => 'some notes',
        'license_files' => [{'path' => '/Users/pivotal/foo/lic1'}, {'path' => '/Users/pivotal/bar/lic2'}],
        'readme_files' => [{'path' => '/Users/pivotal/foo/Readme1'}, {'path' => '/Users/pivotal/bar/Readme2'}]
    }
  end

  before do
    stub(LicenseFinder).config.stub!.whitelist { %w(MIT) }
  end

  describe '.new' do
    it "should mark it as approved when the license is whitelisted" do
      dependency = LicenseFinder::Dependency.new(attributes.merge('license' => 'MIT', 'approved' => false))
      dependency.approved.should == true
    end

    it "should not mark it as approved when the license is not whitelisted" do
      dependency = LicenseFinder::Dependency.new(attributes.merge('license' => 'GPL', 'approved' => false))
      dependency.approved.should == false
    end

    it "should leave it as approved when the license is not whitelisted but it has already been marked as approved" do
      dependency = LicenseFinder::Dependency.new(attributes.merge('license' => 'GPL', 'approved' => true))
      dependency.approved.should == true
    end
  end

  describe '.from_hash' do
    subject { LicenseFinder::Dependency.from_hash(attributes) }

    its(:name) { should == 'spec_name' }
    its(:version) { should == '2.1.3' }
    its(:license) { should == 'GPL' }
    its(:approved) { should == false }
    its(:license_url) { should == "http://www.apache.org/licenses/LICENSE-2.0.html" }
    its(:notes) { should == "some notes" }
    its(:license_files) { should == ["/Users/pivotal/foo/lic1", "/Users/pivotal/bar/lic2"] }
    its(:readme_files) { should == ["/Users/pivotal/foo/Readme1", "/Users/pivotal/bar/Readme2"] }
    its(:to_yaml_entry) { should == "- name: \"spec_name\"\n  version: \"2.1.3\"\n  license: \"GPL\"\n  approved: false\n  license_url: \"http://www.apache.org/licenses/LICENSE-2.0.html\"\n  notes: \"some notes\"\n  license_files:\n  - path: \"/Users/pivotal/foo/lic1\"\n  - path: \"/Users/pivotal/bar/lic2\"\n  readme_files:\n  - path: \"/Users/pivotal/foo/Readme1\"\n  - path: \"/Users/pivotal/bar/Readme2\"\n" }
  end
end


