require 'spec_helper'

module LicenseFinder
  describe PackageSaver do
    let(:package) do
      double(
        :package,
        license: 'license',
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
        dependency.should_receive(:save)
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
          license: LicenseAlias.named('old license')
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
        subject.license.name.should == 'license'
      end

      it "keeps approval" do
        dep = Dependency.create(
          name: 'spec_name',
          manually_approved: true
        )
        saver = described_class.new(dep, package)
        subject = saver.save

        subject.should be_approved
      end
    end
  end
end
