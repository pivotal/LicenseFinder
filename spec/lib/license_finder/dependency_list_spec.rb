require 'spec_helper'

describe LicenseFinder::DependencyList do
  before do
    config = stub(LicenseFinder).config.stub!
    config.whitelist { [] }
    config.ignore_groups { [] }

    @mock_gemspec = Class.new do
      def initialize(name = nil, version = nil, path = nil)
        @name = name
        @version = version
        @path = path
      end

      def name
        @name || 'spec_name'
      end

      def version
        @version || '2.1.3'
      end

      def full_gem_path
        @path || 'install/path'
      end

      def license
        nil
      end
    end
  end

  describe 'from Bundler' do
    subject do
      mock_bundler = Object.new
      stub(Bundler::Definition).build {mock_bundler}
      stub(mock_bundler).groups {[]}
      stub(mock_bundler).specs_for { [@mock_gemspec.new('gem1', '1.2.3'), @mock_gemspec.new('gem2', '0.4.2')] }
      LicenseFinder::DependencyList.from_bundler
    end

    it "should have 2 dependencies" do
      subject.dependencies.size.should == 2
    end

    describe "first" do
      let(:dep) { subject.dependencies.first }
      it { dep.name.should == 'gem1' }
      it { dep.version.should == '1.2.3' }
    end

    describe "second" do
      let(:dep) { subject.dependencies[1] }
      it { dep.name.should == 'gem2' }
      it { dep.version.should == '0.4.2' }
    end

  end

  describe 'from yaml' do
    subject { LicenseFinder::DependencyList.from_yaml("--- \n- name: \"gem1\"\n  version: \"1.2.3\"\n  license: \"MIT\"\n  approved: false\n- name: \"gem2\"\n  version: \"0.4.2\"\n  license: \"MIT\"\n  approved: false\n") }

    it "should have 2 dependencies" do
      subject.dependencies.size.should == 2
    end

    describe "first" do
      let(:dep) { subject.dependencies.first }
      it { dep.name.should == 'gem1' }
      it { dep.version.should == '1.2.3' }
    end

    describe "second" do
      let(:dep) { subject.dependencies[1] }
      it { dep.name.should == 'gem2' }
      it { dep.version.should == '0.4.2' }
    end

  end

  describe 'to_yaml' do
    it "should generate yaml" do
      list = LicenseFinder::DependencyList.new([
                                                   LicenseFinder::Dependency.new('name' => 'b_gem', 'version' => '0.4.2', 'license' => 'MIT', 'approved' => false, 'source' => "bundle"),
                                                   LicenseFinder::Dependency.new('name' => 'a_gem', 'version' => '1.2.3', 'license' => 'MIT', 'approved' => false)
                                               ])

      list.to_yaml.should == "--- \n- name: \"a_gem\"\n  version: \"1.2.3\"\n  license: \"MIT\"\n  approved: false\n  source: \"\"\n  license_url: \"\"\n  notes: \"\"\n  license_files:\n  readme_files:\n- name: \"b_gem\"\n  version: \"0.4.2\"\n  license: \"MIT\"\n  approved: false\n  source: \"bundle\"\n  license_url: \"\"\n  notes: \"\"\n  license_files:\n  readme_files:\n"
    end
  end

  describe 'round trip' do
    it 'should recreate from to_yaml' do
      list = LicenseFinder::DependencyList.new([
                                                   LicenseFinder::Dependency.new('name' => 'gem1', 'version' => '1.2.3', 'license' => 'MIT', 'approved' => false),
                                                   LicenseFinder::Dependency.new('name' => 'gem2', 'version' => '0.4.2', 'license' => 'MIT', 'approved' => false)
                                               ])

      new_list = LicenseFinder::DependencyList.from_yaml(list.to_yaml)
      new_list.dependencies.size.should == 2
      new_list.dependencies.first.name.should == 'gem1'
      new_list.dependencies[1].name.should == 'gem2'
    end
  end

  describe '#merge' do
    before(:each) do
      @yml_same = LicenseFinder::Dependency.new('name' => 'same_gem', 'version' => '1.2.3', 'license' => 'MIT', 'approved' => true, 'license_url' => 'a', 'notes' => 'b')
      @yml_updated = LicenseFinder::Dependency.new('name' => 'updated_gem', 'version' => '1.0.1', 'license' => 'MIT', 'approved' => true, 'license_url' => 'a', 'notes' => 'b')
      @yml_new_license = LicenseFinder::Dependency.new('name' => 'new_license_gem', 'version' => '1.0.1', 'license' => 'MIT', 'approved' => true, 'license_url' => 'a', 'notes' => 'b')
      @yml_manual_license = LicenseFinder::Dependency.new('name' => 'manual_license_gem', 'version' => '1.0.1', 'license' => 'Ruby', 'approved' => true, 'license_url' => 'a', 'notes' => 'b')
      @yml_removed_gem = LicenseFinder::Dependency.new('name' => 'removed_gem', 'version' => '1.0.1', 'license' => 'MIT', 'approved' => true, 'license_url' => 'a', 'notes' => 'b', 'source' => 'bundle')
      @yml_new_whitelist = LicenseFinder::Dependency.new('name' => 'new_whitelist_gem', 'version' => '1.0.1', 'license' => 'MIT', 'approved' => false, 'license_url' => 'a', 'notes' => 'b')
      @yml_non_bundled_dependency = LicenseFinder::Dependency.new('name' => 'non_bundled_dependency', 'version' => '1.0.1', 'license' => 'GPL', 'approved' => false, 'license_url' => 'a', 'notes' => 'b')

      @gemspec_same = LicenseFinder::Dependency.new('name' => 'same_gem', 'version' => '1.2.3', 'license' => 'MIT', 'approved' => false)
      @gemspec_new = LicenseFinder::Dependency.new('name' => 'brand_new_gem', 'version' => '0.9', 'license' => 'MIT', 'approved' => false)
      @gemspec_updated = LicenseFinder::Dependency.new('name' => 'updated_gem', 'version' => '1.1.2', 'license' => 'MIT', 'approved' => false)
      @gemspec_new_license = LicenseFinder::Dependency.new('name' => 'new_license_gem', 'version' => '2.0.1', 'license' => 'Apache 2.0', 'approved' => false)
      @gemspec_new_whitelist = LicenseFinder::Dependency.new('name' => 'new_whitelist_gem', 'version' => '1.0.1', 'license' => 'MIT', 'approved' => true)
      @gemspec_manual_license = LicenseFinder::Dependency.new('name' => 'manual_license_gem', 'version' => '1.2.1', 'license' => 'other', 'approved' => false)

      @list_from_yml = LicenseFinder::DependencyList.new([@yml_same, @yml_non_bundled_dependency, @yml_updated, @yml_new_license, @yml_removed_gem, @yml_new_whitelist, @yml_manual_license])
      @list_from_gemspec = LicenseFinder::DependencyList.new([@gemspec_same, @gemspec_new, @gemspec_updated, @gemspec_new_license, @gemspec_new_whitelist, @gemspec_manual_license])
    end

    it "should ignore existing gems with the same version" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'same_gem' }
      dep.approved.should == @yml_same.approved
      dep.license_url.should == 'a'
      dep.notes.should == 'b'
    end

    it "should keep old license value if gemspec license is other" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'manual_license_gem' }
      dep.license.should == @yml_manual_license.license
      dep.version.should == @gemspec_manual_license.version
      dep.approved.should == @yml_manual_license.approved
      dep.license_url.should == 'a'
      dep.notes.should == 'b'
    end

    it "should use the new source" do
      old_deps = [LicenseFinder::Dependency.new('name' => 'foo', 'license' => 'MIT')]
      new_deps = [LicenseFinder::Dependency.new('name' => 'foo', 'license' => 'other', 'source' => 'bundle')]

      list = LicenseFinder::DependencyList.new(old_deps).merge(LicenseFinder::DependencyList.new(new_deps))
      dep = list.dependencies.first
      dep.source.should == 'bundle'
    end

    it "should add new gem" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'brand_new_gem' }
      dep.should_not be_nil
      dep.version.should == @gemspec_new.version
      dep.approved.should == @gemspec_new.approved
      dep.license.should == @gemspec_new.license
      dep.license_url.should == ''
      dep.notes.should == ''
    end

    it "should update version if gem exists and license is the same" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'updated_gem' }
      dep.name.should == @gemspec_updated.name
      dep.approved.should == @yml_updated.approved
      dep.license_url.should == 'a'
      dep.notes.should == 'b'
    end

    it "should replace gem if version and license are different" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'new_license_gem' }
      dep.name.should == @gemspec_new_license.name
      dep.version.should == @gemspec_new_license.version
      dep.approved.should == @gemspec_new_license.approved
      dep.license_url.should == ''
      dep.notes.should == ''
    end

    it "should update approved if gemspec gem is approved" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'new_whitelist_gem' }
      dep.name.should == @gemspec_new_whitelist.name
      dep.version.should == @gemspec_new_whitelist.version
      dep.approved.should == @gemspec_new_whitelist.approved
      dep.license_url.should == 'a'
      dep.notes.should == 'b'
    end

    it "should remove gem if new list doesn't contain it" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'removed_gem' }
      dep.should be_nil
    end

    it "should keep any manually added dependencies that aren't part of the bundle" do
      dependencies = @list_from_yml.merge(@list_from_gemspec).dependencies
      dep = dependencies.detect { |d| d.name == 'non_bundled_dependency' }
      dep.should_not be_nil
    end
  end

  describe "#to_s" do
    it "should return a human readable list of dependencies" do
      gem1 = LicenseFinder::Dependency.new('name' => 'b_gem', 'version' => '1.2.3', 'license' => 'MIT', 'approved' => true)
      gem2 = LicenseFinder::Dependency.new('name' => 'a_gem', 'version' => '0.9', 'license' => 'other', 'approved' => false, 'license_url' => 'http://foo.com/LICENSE')

      list = LicenseFinder::DependencyList.new([gem1, gem2])

      list.to_s.should == "a_gem 0.9, other, http://foo.com/LICENSE\n  license files:\n  readme files:\nb_gem 1.2.3, MIT"
    end
  end

  describe '#action_items' do
    it "should return all unapproved dependencies" do
      gem1 = LicenseFinder::Dependency.new('name' => 'b_gem', 'version' => '1.2.3', 'license' => 'MIT', 'approved' => true)
      gem2 = LicenseFinder::Dependency.new('name' => 'a_gem', 'version' => '0.9', 'license' => 'other', 'approved' => false)
      gem3 = LicenseFinder::Dependency.new('name' => 'c_gem', 'version' => '0.2', 'license' => 'other', 'approved' => false)

      list = LicenseFinder::DependencyList.new([gem1, gem2, gem3])

      list.action_items.should == "a_gem 0.9, other\n  license files:\n  readme files:\nc_gem 0.2, other\n  license files:\n  readme files:"
    end
  end
end


