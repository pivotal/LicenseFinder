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
      it { dep.to_yaml_entry.should == "- name: \"gem1\"\n  version: \"1.2.3\"\n  license: \"MIT\"\n  approved: false\n" }
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
                                                   LicenseFinder::Dependency.new('gem1', '1.2.3', 'MIT', false),
                                                   LicenseFinder::Dependency.new('gem2', '0.4.2', 'MIT', false)
                                               ])

      list.to_yaml.should == "--- \n- name: \"gem1\"\n  version: \"1.2.3\"\n  license: \"MIT\"\n  approved: false\n- name: \"gem2\"\n  version: \"0.4.2\"\n  license: \"MIT\"\n  approved: false\n"
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
end


