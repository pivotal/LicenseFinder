require 'spec_helper'

module LicenseFinder
  describe GemSaver do
    let(:gemspec) do
      Gem::Specification.new do |s|
        s.name = 'spec_name'
        s.version = '2.1.3'
        s.summary = 'summary'
        s.description = 'description'
        s.homepage = 'homepage'

        s.add_dependency 'foo'
      end
    end

    describe "#save" do
      let(:bundled_gem) { BundledGem.new(gemspec) }
      subject { described_class.find_or_initialize_by_name('spec_name', bundled_gem).save }

      context "when the dependency is new" do
        it "persists gem data" do
          subject.id.should be
          subject.name.should == "spec_name"
          subject.version.should == "2.1.3"
          subject.summary.should == "summary"
          subject.description.should == "description"
          subject.homepage.should == "homepage"
        end

        it "associates children" do
          subject.children.map(&:name).should == ['foo']
        end

        it "marks depenency as unapproved by default" do
          subject.approval.state.should == nil
        end

        context "with a bundler dependency" do
          let(:bundled_gem) { BundledGem.new(gemspec, stub(:bundler_dependency, groups: %w[1 2 3]))}

          it "saves the bundler groups" do
            subject.bundler_groups.map(&:name).should =~ %w[1 2 3]
          end
        end
      end

      context "when the dependency already existed" do
        let!(:old_copy) do
          Dependency.create(
            name: 'spec_name',
            version: '0.1.2',
            summary: 'old summary',
            description: 'old desription',
            homepage: 'old homepage'
          )
        end

        it "merges in the latest data" do
          subject.id.should == old_copy.id
          subject.name.should == old_copy.name
          subject.version.should == "2.1.3"
          subject.summary.should == "summary"
          subject.description.should == "description"
          subject.homepage.should == "homepage"
        end

        it "keeps a manually assigned license" do
          old_copy.license = LicenseAlias.create(name: 'foo', manual: true)
          old_copy.save
          subject.license.name.should == 'foo'
        end

        it "keeps approval" do
          old_copy.approval = Approval.create(state: true)
          old_copy.save
          subject.approval.state.should == true
        end

        it "ensures correct children are associated" do
          old_copy.add_child Dependency.new(name: 'bob')
          old_copy.add_child Dependency.new(name: 'joe')
          old_copy.children.each(&:save)
          subject.children.map(&:name).should =~ ['foo']
        end

        context "with a bundler dependency" do
          let(:bundled_gem) { BundledGem.new(gemspec, stub(:bundler_dependency, groups: %w[1 2 3]))}

          before do
            old_copy.add_bundler_group BundlerGroup.find_or_create(name: 'a')
            old_copy.add_bundler_group BundlerGroup.find_or_create(name: 'b')
          end

          it "ensures the correct bundler groups are associated" do
            subject.bundler_groups.map(&:name).should =~ %w[1 2 3]
          end
        end

        context "license changes to something other than 'other'" do
          before do
            old_copy.license = LicenseAlias.create(name: 'other')
            old_copy.save
            gemspec.license = "new license"
          end

          context "new license is whitelisted" do
            before { LicenseFinder.config.stub(:whitelist).and_return [gemspec.license] }

            it "should set the approval to true" do
              subject.should be_approved
            end
          end

          context "new license is not whitelisted" do
            it "should set the approval to false" do
              subject.should_not be_approved
            end
          end
        end

        context "license changes to unknown (i.e., 'other')" do
          before do
            old_copy.license = LicenseAlias.create(name: 'MIT')
            old_copy.approval = Approval.create(state: false)
            old_copy.save
            gemspec.license = "other"
          end

          it "should not change the license" do
            subject.license.name.should == 'MIT'
          end

          it "should not change the approval" do
            subject.should_not be_approved
          end
        end

        context "license does not change" do
          before do
            old_copy.license = LicenseAlias.create(name: 'MIT')
            old_copy.approval = Approval.create(state: false)
            old_copy.save
            gemspec.license = "MIT"
          end

          it "should not change the license or approval" do
            subject.should_not be_approved
            subject.license.name.should == "MIT"
          end
        end
      end
    end
  end
end
