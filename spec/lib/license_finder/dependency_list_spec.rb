require 'spec_helper'

module LicenseFinder
  describe DependencyList do
    def build_gemspec(name, version, dependency=nil)
      Gem::Specification.new do |s|
        s.name = name
        s.version = version
        s.summary = 'summary'
        s.description = 'description'

        if dependency
          s.add_dependency dependency
        end
      end
    end

    before do
      LicenseFinder.stub(:config).and_return(double('config', {
        :whitelist => [],
        :ignore_groups => []
      }))
    end

    describe '.from_bundler' do
      subject do
        Bundler::Definition.stub(:build).and_return(definition)
        DependencyList.from_bundler
      end

      let(:definition) do
        double('definition', {
          :dependencies => [],
          :groups => [],
          :specs_for => [
            build_gemspec('gem1', '1.2.3'),
            build_gemspec('gem2', '0.4.2')
          ]
        })
      end

      it "should have 2 dependencies" do
        subject.dependencies.size.should == 2
      end

      it 'should maintain the incoming order' do
        subject.dependencies[0].name.should == 'gem1'
        subject.dependencies[0].version.should == '1.2.3'

        subject.dependencies[1].name.should == 'gem2'
        subject.dependencies[1].version.should == '0.4.2'
      end

      context "when initialized with a parent and child gem" do
        before do
          definition.stub(:specs_for).and_return([
            build_gemspec('gem1', '1.2.3', 'gem2'),
            build_gemspec('gem2', '0.4.2')
          ])
        end

        it "should update the child dependency with its parent data" do
          gem1 = subject.dependencies.first
          gem2 = subject.dependencies.last

          gem2.parents.should == [gem1.name]
          gem1.children.should == [gem2.name]
        end
      end
    end

    describe '#save!' do
      it "should save all the dependencies in the list" do
        dep1 = double('dependency 1')
        dep1.should_receive(:save!)
        dep2 = double('dependency 2')
        dep2.should_receive(:save!)

        dep_list = DependencyList.new([dep1, dep2])
        dep_list.save!
      end
    end

    describe '#from_yaml' do
      subject do
        DependencyList.from_yaml([
          {'name' => 'gem1', 'version' => '1.2.3', 'license' => 'MIT', 'approved' => false},
          {'name' => 'gem2', 'version' => '0.4.2', 'license' => 'MIT', 'approved' => false}
        ].to_yaml)
      end

      it 'should have 2 dependencies' do
        subject.dependencies.size.should == 2
      end

      it 'should maintain the incoming order' do
        subject.dependencies[0].name.should == 'gem1'
        subject.dependencies[0].version.should == '1.2.3'

        subject.dependencies[1].name.should == 'gem2'
        subject.dependencies[1].version.should == '0.4.2'
      end
    end

    describe '#as_yaml' do
      it "should return an array of sorted dependencies converted to as_yaml hashes" do
        dep1 = double('dependency 1', :name => 'foo', :as_yaml => 'foo')
        dep2 = double('dependency 2', :name => 'bar', :as_yaml => 'bar')

        list = DependencyList.new([
          dep1, dep2
        ])

        list.as_yaml.should == %w(bar foo)
      end
    end

    describe '#to_yaml' do
      it "should generate yaml" do
        list = DependencyList.new([
          LicenseFinder::Dependency.new('name' => 'b_gem', 'version' => '0.4.2', 'license' => 'MIT', 'approved' => false, 'source' => "bundle"),
          LicenseFinder::Dependency.new('name' => 'a_gem', 'version' => '1.2.3', 'license' => 'MIT', 'approved' => false)
        ])

        yaml = YAML.load(list.to_yaml)
        yaml.should == list.as_yaml
      end
    end

    describe 'round trip' do
      it 'should recreate from to_yaml' do
        list = DependencyList.new([
          LicenseFinder::Dependency.new('name' => 'gem1', 'version' => '1.2.3', 'license' => 'MIT', 'approved' => false),
          LicenseFinder::Dependency.new('name' => 'gem2', 'version' => '0.4.2', 'license' => 'MIT', 'approved' => false)
        ])

        new_list = DependencyList.from_yaml(list.to_yaml)
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
      let(:old_list) { DependencyList.new([old_dep]) }

      let(:new_dep) do
        LicenseFinder::Dependency.new(
          'name' => 'foo',
          'version' => '0.0.2',
          'source' => 'bundle'
        )
      end
      let(:new_list) { DependencyList.new([new_dep]) }

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

        gem1 = Struct.new(:name, :to_s).new("a", "a string")
        gem2 = Struct.new(:name, :to_s).new("b", "b string")

        list = DependencyList.new([gem2, gem1])

        list.to_s.should == "a string\nb string"
      end
    end

    describe '#action_items' do
      it "should return all unapproved dependencies" do
        gem1 = LicenseFinder::Dependency.new('name' => 'a', 'approved' => true)
        gem1.stub(:to_s).and_return('a string')

        gem2 = LicenseFinder::Dependency.new('name' => 'b', 'approved' => false)
        gem2.stub(:to_s).and_return('b string')

        gem3 = LicenseFinder::Dependency.new('name' => 'c', 'approved' => false)
        gem3.stub(:to_s).and_return('c string')

        list = DependencyList.new([gem1, gem2, gem3])

        list.action_items.should == "b string\nc string"
      end
    end

    describe '#to_html' do
      it "should concatenate the results of the each dependency's #to_html and plop it into a proper HTML document" do
        gem1 = LicenseFinder::Dependency.new('name' => 'a')
        gem1.stub(:to_html).and_return('A')

        gem2 = LicenseFinder::Dependency.new('name' => 'b')
        gem2.stub(:to_html).and_return('B')

        list = DependencyList.new([gem1, gem2])

        html = list.to_html
        html.should include "A"
        html.should include "B"
      end
    end
  end
end
