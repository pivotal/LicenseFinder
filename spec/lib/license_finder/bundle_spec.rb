require "spec_helper"

module LicenseFinder
  describe Bundle do
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

    describe '.current_gems' do
      subject do
        Bundle.current_gems(definition)
      end

      it "should have 2 dependencies" do
        subject.size.should == 2
      end

      context "when initialized with a parent and child gem" do
        before do
          definition.stub(:specs_for).and_return([
            build_gemspec('gem1', '1.2.3', 'gem2'),
            build_gemspec('gem2', '0.4.2', 'gem3')
          ])
        end

        it "should update the child dependency with its parent data" do
          gem1 = subject.first

          gem1.children.should == ["gem2"]
        end

        it "should only include the children which are project dependencies" do
          gem2 = subject[1]

          gem2.children.should == []
        end
      end
    end
  end
end
