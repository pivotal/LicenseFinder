require 'spec_helper'

describe LicenseFinder::DependencyList do
  before do
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
    end

  end

  describe 'from Bundler' do
    subject do
      stub(Bundler).load.stub!.specs { [@mock_gemspec.new('gem1', '1.2.3'), @mock_gemspec.new('gem2', '0.4.2')] }
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
                                                   LicenseFinder::Dependency.new('b_gem', '0.4.2', 'MIT', false),
                                                   LicenseFinder::Dependency.new('a_gem', '1.2.3', 'MIT', false)
                                               ])

      list.to_yaml.should == "--- \n- name: \"a_gem\"\n  version: \"1.2.3\"\n  license: \"MIT\"\n  approved: false\n  license_url: \"\"\n  notes: \"\"\n- name: \"b_gem\"\n  version: \"0.4.2\"\n  license: \"MIT\"\n  approved: false\n  license_url: \"\"\n  notes: \"\"\n"
    end
  end

  describe 'round trip' do
    it 'should recreate from to_yaml' do
      list = LicenseFinder::DependencyList.new([
                                                   LicenseFinder::Dependency.new('gem1', '1.2.3', 'MIT', false),
                                                   LicenseFinder::Dependency.new('gem2', '0.4.2', 'MIT', false)
                                               ])

      new_list = LicenseFinder::DependencyList.from_yaml(list.to_yaml)
      new_list.dependencies.size.should == 2
      new_list.dependencies.first.name.should == 'gem1'
      new_list.dependencies[1].name.should == 'gem2'
    end
  end

  describe 'updating dependency list' do
    before(:each) do
      @yml_same = LicenseFinder::Dependency.new('same_gem', '1.2.3', 'MIT', true)
      @yml_updated = LicenseFinder::Dependency.new('updated_gem', '1.0.1', 'MIT', true)
      @yml_new_license = LicenseFinder::Dependency.new('new_license_gem', '1.0.1', 'MIT', true)
      @yml_manual_license = LicenseFinder::Dependency.new('manual_license_gem', '1.0.1', 'Ruby', true)
      @yml_removed_gem = LicenseFinder::Dependency.new('removed_gem', '1.0.1', 'MIT', true)
      @yml_new_whitelist = LicenseFinder::Dependency.new('new_whitelist_gem', '1.0.1', 'MIT', false)

      @gemspec_same = LicenseFinder::Dependency.new('same_gem', '1.2.3', 'MIT', false)
      @gemspec_new = LicenseFinder::Dependency.new('brand_new_gem', '0.9', 'MIT', false)
      @gemspec_updated = LicenseFinder::Dependency.new('updated_gem', '1.1.2', 'MIT', false)
      @gemspec_new_license = LicenseFinder::Dependency.new('new_license_gem', '2.0.1', 'Apache 2.0', false)
      @gemspec_new_whitelist = LicenseFinder::Dependency.new('new_whitelist_gem', '1.0.1', 'MIT', true)
      @gemspec_manual_license = LicenseFinder::Dependency.new('manual_license_gem', '1.2.1', 'other', false)

      @list_from_yml = LicenseFinder::DependencyList.new([@yml_same, @yml_updated, @yml_new_license, @yml_removed_gem, @yml_new_whitelist, @yml_manual_license])
      @list_from_gemspec = LicenseFinder::DependencyList.new([@gemspec_same, @gemspec_new, @gemspec_updated, @gemspec_new_license, @gemspec_new_whitelist, @gemspec_manual_license])
    end

    it "should ignore existing gems with the same version" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'same_gem' }
      dep.approved.should == @yml_same.approved
    end

    it "should keep old license value if gemspec license is other" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'manual_license_gem' }
      dep.license.should == @yml_manual_license.license
      dep.version.should == @gemspec_manual_license.version
      dep.approved.should == @yml_manual_license.approved
    end

    it "should add new gem" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'brand_new_gem' }
      dep.should_not be_nil
      dep.version.should == @gemspec_new.version
      dep.approved.should == @gemspec_new.approved
      dep.license.should == @gemspec_new.license
    end

    it "should update version if gem exists and license is the same" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'updated_gem' }
      dep.name.should == @gemspec_updated.name
      dep.approved.should == @yml_updated.approved
    end

    it "should replace gem if version and license are different" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'new_license_gem' }
      dep.name.should == @gemspec_new_license.name
      dep.version.should == @gemspec_new_license.version
      dep.approved.should == @gemspec_new_license.approved
    end

    it "should update approved if gemspec gem is approved" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'new_whitelist_gem' }
      dep.name.should == @gemspec_new_whitelist.name
      dep.version.should == @gemspec_new_whitelist.version
      dep.approved.should == @gemspec_new_whitelist.approved
    end


    it "should remove gem if new list doesn't contain it" do
      dep = @list_from_yml.merge(@list_from_gemspec).dependencies.detect { |d| d.name == 'removed_gem' }
      dep.should be_nil
    end
  end

  describe "#to_s" do
    it "should return a human readable list of dependencies" do
      gem1 = LicenseFinder::Dependency.new('b_gem', '1.2.3', 'MIT', true)
      gem2 = LicenseFinder::Dependency.new('a_gem', '0.9', 'other', false, 'http://foo.com/LICENSE')

      list = LicenseFinder::DependencyList.new([gem1, gem2])

      list.to_s.should == "a_gem 0.9, other, http://foo.com/LICENSE\nb_gem 1.2.3, MIT"
    end
  end

  describe '#action_items' do
    it "should return all unapproved dependencies" do
      gem1 = LicenseFinder::Dependency.new('b_gem', '1.2.3', 'MIT', true)
      gem2 = LicenseFinder::Dependency.new('a_gem', '0.9', 'other', false)
      gem3 = LicenseFinder::Dependency.new('c_gem', '0.2', 'other', false)

      list = LicenseFinder::DependencyList.new([gem1, gem2, gem3])

      list.action_items.should == "a_gem 0.9, other\nc_gem 0.2, other"
    end
  end
end


