require 'spec_helper'

module LicenseFinder
  describe PackageSaver do
    let(:package) do
      double(
        :package,
        licenses: [License.find_by_name('license')],
        children: ['child'],
        groups: [:group],
        summary: 'summary',
        description: 'description',
        name: 'spec_name',
        version: '1.2.3',
        homepage: 'http://example.com'
      )
    end

    describe ".save_all" do
      let(:dependency) { double(:dependency).as_null_object }

      it "find and updates relevant dependencies" do
        Dependency.should_receive(:named).with('spec_name').and_return(dependency)
        dependency.should_receive(:save_changes)
        described_class.save_all([package])
      end
    end

    describe "#save" do
      it "persists changes" do
        dep = Dependency.create(
          name: 'spec_name',
          version: '0.1.2',
          summary: 'old summary',
          description: 'old desription',
          homepage: 'old homepage',
          license_names: ["old license"].to_json
        )
        dep.add_bundler_group BundlerGroup.named("old group")
        dep.add_child Dependency.named("old child")

        saver = described_class.new(dep, package)
        subject = saver.save

        subject.id.should be
        subject.name.should == "spec_name"
        subject.version.should == "1.2.3"
        subject.summary.should == "summary"
        subject.description.should == "description"
        subject.homepage.should == "http://example.com"
        subject.bundler_groups.map(&:name).should == ['group']
        subject.children.map(&:name).should == ['child']
        subject.licenses.first.name.should == 'license'
      end

      it "keeps approval" do
        dep = Dependency.create(
          name: 'spec_name',
        )
        dep.approve!
        saver = described_class.new(dep, package)
        subject = saver.save

        subject.should be_approved
      end

      context "to minimize db changes" do
        it "does not re-save unchanged dependencies" do
          # See note in PackageSaver#save

          first_run = described_class.find_or_create_by_name(package)
          # Can't set this expectation, because rspec method expectations
          # have no way to allow the real save to happen.
          # expect(first_run.dependency).to receive(:save)
          first_run.save

          second_run = described_class.find_or_create_by_name(package)
          expect(second_run.dependency).to_not receive(:save)
          second_run.save
        end

        it "saves new dependencies" do
          # Just a sanity check that the above test is testing what we think it
          # is testing.
          saver = described_class.find_or_create_by_name(package)
          expect(saver.dependency).to receive(:save)
          saver.save
        end
      end
    end
  end
end
