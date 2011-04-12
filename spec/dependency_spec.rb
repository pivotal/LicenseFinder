require 'spec_helper'

class LicenseFinder::MockGemSpec3
  def initialize(path = nil)
    @path = path
  end

  def name
    'spec_name'
  end

  def version
    '2.1.3'
  end

  def full_gem_path
    @path || 'install/path'
  end
end

#--
#  name: activerecord
#  version: 3.0.5
#  license: MIT
#  approved: true
#  license_url: http://foo.com/README
#  notes: some notes
#  license_files:
#  - path: /Users/pivotal/foo/lic1
#  - path:  /Users/pivotal/bar/lic2
#  readme_files:
#  - path: /Users/pivotal/foo/Readme1
#  - path: /Users/pivotal/bar/Readme2

describe LicenseFinder::Dependency do

  describe 'from hash' do
    subject { LicenseFinder::Dependency.from_hash({'name' => "spec_name", 'version' => "2.1.3", 'license' => "MIT", 'approved' => false,
                                                   'license_url' => 'http://www.apache.org/licenses/LICENSE-2.0.html', 'notes' => 'some notes',
                                                   'license_files' => [{'path' => '/Users/pivotal/foo/lic1'}, {'path' => '/Users/pivotal/bar/lic2'}],
                                                   'readme_files' => [{'path' => '/Users/pivotal/foo/Readme1'}, {'path' => '/Users/pivotal/bar/Readme2'}]}) }

    its(:name) { should == 'spec_name' }
    its(:version) { should == '2.1.3' }
    its(:license) { should == 'MIT' }
    its(:approved) { should == false }
    its(:license_url) { should == "http://www.apache.org/licenses/LICENSE-2.0.html" }
    its(:notes) { should == "some notes" }
    its(:license_files) { should == ["/Users/pivotal/foo/lic1", "/Users/pivotal/bar/lic2"] }
    its(:readme_files) { should == ["/Users/pivotal/foo/Readme1", "/Users/pivotal/bar/Readme2"] }

    its(:to_yaml_entry) {should == "- name: \"spec_name\"\n  version: \"2.1.3\"\n  license: \"MIT\"\n  approved: false\n  license_url: \"http://www.apache.org/licenses/LICENSE-2.0.html\"\n  notes: \"some notes\"\n  license_files:\n  - path: \"/Users/pivotal/foo/lic1\"\n  - path: \"/Users/pivotal/bar/lic2\"\n  readme_files:\n  - path: \"/Users/pivotal/foo/Readme1\"\n  - path: \"/Users/pivotal/bar/Readme2\"\n"}
  end

end


