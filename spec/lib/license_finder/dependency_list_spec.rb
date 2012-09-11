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
      stub(mock_bundler).dependencies { [] }
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

  describe '#from_yaml' do
    subject do
      LicenseFinder::DependencyList.from_yaml([
        {'name' => 'gem1', 'version' => '1.2.3', 'license' => 'MIT', 'approved' => false},
        {'name' => 'gem2', 'version' => '0.4.2', 'license' => 'MIT', 'approved' => false}
      ].to_yaml)
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

  describe '#as_yaml' do
    it "should generate yaml" do
      list = LicenseFinder::DependencyList.new([
        LicenseFinder::Dependency.new('name' => 'b_gem', 'version' => '0.4.2', 'license' => 'MIT', 'approved' => false, 'source' => "bundle"),
        LicenseFinder::Dependency.new('name' => 'a_gem', 'version' => '1.2.3', 'license' => 'MIT', 'approved' => false)
      ])

      list.as_yaml.should == [
        {
          'name' => 'a_gem',
          'version' => '1.2.3',
          'license' => 'MIT',
          'approved' => false,
          'source' => nil,
          'license_url' => '',
          'notes' => '',
          'license_files' => nil,
          'readme_files' => nil
        },
        {
          'name' => 'b_gem',
          'version' => '0.4.2',
          'license' => 'MIT',
          'approved' => false,
          'source' => 'bundle',
          'license_url' => '',
          'notes' => '',
          'license_files' => nil,
          'readme_files' => nil
        }
      ]
    end
  end


  describe '#to_yaml' do
    it "should generate yaml" do
      list = LicenseFinder::DependencyList.new([
        LicenseFinder::Dependency.new('name' => 'b_gem', 'version' => '0.4.2', 'license' => 'MIT', 'approved' => false, 'source' => "bundle"),
        LicenseFinder::Dependency.new('name' => 'a_gem', 'version' => '1.2.3', 'license' => 'MIT', 'approved' => false)
      ])

      yaml = YAML.load(list.to_yaml)
      yaml.should == list.as_yaml
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
    let(:old_dep) do
      LicenseFinder::Dependency.new(
        'name' => 'foo',
        'version' => '0.0.1',
        'source' => 'bundle'
      )
    end
    let(:old_list) { LicenseFinder::DependencyList.new([old_dep]) }

    let(:new_dep) do
      LicenseFinder::Dependency.new(
        'name' => 'foo',
        'version' => '0.0.2',
        'source' => 'bundle'
      )
    end
    let(:new_list) { LicenseFinder::DependencyList.new([new_dep]) }

    it 'should merge dependencies with the same name' do
      merged_list = old_list.merge(new_list)

      merged_deps = merged_list.dependencies.select { |d| d.name == 'foo' }
      merged_deps.should have(1).item

      merged_dep = merged_deps.first
      merged_dep.name.should == 'foo'
      merged_dep.version.should == '0.0.2'
    end

    it 'should add new dependencies' do
      new_dep.name = 'bar'

      merged_list = old_list.merge(new_list)
      merged_list.dependencies.should include(new_dep)
    end

    it 'should keep dependencies not originating from the bundle' do
      old_dep.source = ''

      merged_list = old_list.merge(new_list)
      merged_list.dependencies.should include(old_dep)
    end

    it 'should remove dependencies missing from the bundle' do
      old_dep.source = 'bundle'

      merged_list = old_list.merge(new_list)
      merged_list.dependencies.should_not include(old_dep)
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


