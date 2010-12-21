require 'spec_helper'

class LicenseFinder::MockGemSpec
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

describe LicenseFinder::Finder do
  subject { LicenseFinder::Finder.new(LicenseFinder::MockGemSpec.new) }

  its(:name) { should == 'spec_name 2.1.3' }
  its(:dependency_name) { should == 'spec_name' }
  its(:dependency_version) { should == '2.1.3' }
  its(:install_path) { should == 'install/path' }

  describe "#license_files" do
    it "is empty if there aren't any license files" do
      LicenseFinder::Finder.new(LicenseFinder::MockGemSpec.new).license_files.should == []
    end
    it "includes files with names like LICENSE, License or COPYING" do
      gem_spec = LicenseFinder::MockGemSpec.new('spec/fixtures/license_names')
      LicenseFinder::Finder.new(gem_spec).license_files.map(&:file_name).sort.should ==
        %w[COPYING.txt LICENSE Mit-License]
    end
    it "includes files deep in the hierarchy" do
      gem_spec = LicenseFinder::MockGemSpec.new('spec/fixtures/nested_gem')
      LicenseFinder::Finder.new(gem_spec).license_files.map { |f| [f.file_name, f.file_path]}.should ==
        [['LICENSE', 'vendor/LICENSE']]
    end
  end
end
