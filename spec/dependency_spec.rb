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

describe LicenseFinder::Dependency do


  describe 'from hash' do
    subject { LicenseFinder::Dependency.from_hash({'name' => "spec_name", 'version' => "2.1.3", 'license' => "MIT", 'approved' => false}) }

    its(:name) { should == 'spec_name' }
    its(:version) { should == '2.1.3' }
    its(:license) { should == 'MIT' }
    its(:approved) { should == false }

    its(:to_yaml_entry) {should == "- name: \"spec_name\"\n  version: \"2.1.3\"\n  license: \"MIT\"\n  approved: false\n" }

  end

end


