require 'spec_helper'

describe LicenseFinder::GemSpecDetails do
  before do
    @mock_gemspec = Class.new do
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
  end

  subject { LicenseFinder::GemSpecDetails.new(@mock_gemspec.new) }

  its(:name) { should == 'spec_name 2.1.3' }
  its(:dependency_name) { should == 'spec_name' }
  its(:dependency_version) { should == '2.1.3' }
  its(:install_path) { should == 'install/path' }

  describe "#license_files" do
    it "is empty if there aren't any license files" do
      LicenseFinder::GemSpecDetails.new(@mock_gemspec.new).license_files.should == []
    end
    it "includes files with names like LICENSE, License or COPYING" do
      gem_spec = @mock_gemspec.new('spec/fixtures/license_names')
      LicenseFinder::GemSpecDetails.new(gem_spec).license_files.map(&:file_name).should =~
          %w[COPYING.txt LICENSE Mit-License]
    end
    it "includes files deep in the hierarchy" do
      gem_spec = @mock_gemspec.new('spec/fixtures/nested_gem')
      LicenseFinder::GemSpecDetails.new(gem_spec).license_files.map { |f| [f.file_name, f.file_path] }.should =~
          [['LICENSE', 'vendor/LICENSE']]
    end
  end

  describe "#readme_files" do
    it "is empty if there aren't any readmes" do
      LicenseFinder::GemSpecDetails.new(@mock_gemspec.new).readme_files.should == []
    end

    it "includes files named README" do
      gem_spec = @mock_gemspec.new('spec/fixtures/readme')
      LicenseFinder::GemSpecDetails.new(gem_spec).readme_files.map(&:file_name).sort.should =~
          ['README', 'Readme.markdown', 'Project ReadMe']
    end

    it "includes files deep in the hierarchy" do
      gem_spec = @mock_gemspec.new('spec/fixtures/nested_readme')
      LicenseFinder::GemSpecDetails.new(gem_spec).readme_files.map { |f| [f.file_name, f.file_path] }.should =~
          [['README', 'vendor/README']]
    end
  end

  describe 'to dependency' do
    subject { LicenseFinder::GemSpecDetails.new(@mock_gemspec.new).dependency }

    its(:name) { should == 'spec_name' }
    its(:version) { should == '2.1.3' }
    its(:license) { should == 'MIT' }
    its(:approved) { should == false }

    its(:to_yaml_entry) { should == "- name: \"spec_name\"\n  version: \"2.1.3\"\n  license: \"MIT\"\n  approved: false\n" }

  end
end
