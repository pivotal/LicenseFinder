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

    describe '.from_bundler(bundle)' do
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

      subject do
        DependencyList.from_bundler(Bundle.new(definition))
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
  end
end
