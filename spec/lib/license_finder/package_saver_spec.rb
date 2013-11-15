require 'spec_helper'

module LicenseFinder
  describe PackageSaver do
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

    describe ".save_all" do
      let(:packages) { [gem] }
      let(:gem) { double(:package) }

      it "calls find_or_create_by_name on all passed in gems" do
        described_class.should_receive(:find_or_create_by_name).with(gem).and_return(gem)
        gem.should_receive(:save)
        described_class.save_all(packages)
      end
    end

    describe "#save" do
      let(:package) { Package.new(gemspec) }
      subject { described_class.find_or_create_by_name(package).save }

      before { package.children = ["foo"] }

      context "when the dependency is new" do
        it "persists gem data" do
          subject.id.should be
          subject.name.should == "spec_name"
          subject.version.should == "2.1.3"
          subject.summary.should == "summary"
          subject.description.should == "description"
          subject.homepage.should == "homepage"
        end

        describe "associating children" do
          it "associates children" do
            subject.children.map(&:name).should == ['foo']
            subject.children.each { |child| child.id.should_not be_nil }
          end
        end

        it "marks depenency as unapproved by default" do
          subject.approval.state.should == nil
        end

        context "with a bundler dependency" do
          let(:package) { Package.new(gemspec, double(:bundler_dependency, groups: %w[1 2 3]))}

          it "saves the bundler groups" do
            subject.bundler_groups.map(&:name).should =~ %w[1 2 3]
          end
        end
      end

      context "when the dependency already existed" do
        before { LicenseFinder.stub(:current_gems).and_return([double(:gemspec, name: "foo 0.0")]) }

        let!(:old_copy) do
          dep = Dependency.create(
            name: 'spec_name',
            version: '0.1.2',
            summary: 'old summary',
            description: 'old desription',
            homepage: 'old homepage'
          )
          dep.approval = Approval.create
          dep
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
          old_copy.license = LicenseAlias.create(name: 'foo')
          old_copy.license_manual = true
          old_copy.save
          subject.license.name.should == 'foo'
        end

        it "keeps approval" do
          old_copy.approval = Approval.create(state: true)
          old_copy.save
          subject.approval.state.should
          if LicenseFinder::Platform.java?
            subject.approval.state.should == 1
          else
            subject.approval.state.should == true
          end
        end

        it "ensures correct children are associated" do
          old_copy.add_child Dependency.new(name: 'bob')
          old_copy.add_child Dependency.new(name: 'joe')
          old_copy.children.each(&:save)
          subject.children.map(&:name).should =~ ['foo']
        end

        context "with a bundler dependency" do
          let(:package) { Package.new(gemspec, double(:bundler_dependency)) }

          before do
            package.stub(:groups) { [:group_1, :group_2, :b] }
            old_copy.add_bundler_group BundlerGroup.find_or_create(name: 'a')
            old_copy.add_bundler_group BundlerGroup.find_or_create(name: 'b')
          end

          it "ensures the correct bundler groups are associated" do
            subject.bundler_groups.map(&:name).should =~ %w[group_1 group_2 b]
          end
        end

        context "license has changed" do
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

          context "license already exists" do
            it "uses the existing license" do
              new_license = LicenseAlias.create(name: 'new license')
              subject.license.should == new_license
            end
          end
        end

        context "license does not change" do
          let(:package_saver) { described_class.find_or_create_by_name(package) }

          before do
            old_copy.license = LicenseAlias.create(name: 'MIT')
            old_copy.approval = Approval.create(state: false)
            old_copy.save
            gemspec.license = "MIT"
          end

          it "should not change the license or approval" do
            dependency = package_saver.save
            if LicenseFinder::Platform.java?
              dependency.approved?.should_not == 1
            else
              dependency.should_not be_approved
            end
            dependency.license.name.should == "MIT"
          end
        end
      end
    end
  end
end
