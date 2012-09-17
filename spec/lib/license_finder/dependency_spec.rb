require 'spec_helper'

module LicenseFinder
  describe Dependency do
    let(:attributes) do
      {
        'name' => "spec_name",
        'version' => "2.1.3",
        'license' => "GPLv2",
        'approved' => false,
        'notes' => 'some notes',
        'homepage' => 'homepage',
        'license_files' => ['/Users/pivotal/foo/lic1', '/Users/pivotal/bar/lic2'],
        'readme_files' => ['/Users/pivotal/foo/Readme1', '/Users/pivotal/bar/Readme2'],
        'source' => "bundle",
        'bundler_groups' => ["test"]
      }
    end

    before do
      stub(LicenseFinder).config.stub!.whitelist { %w(MIT) }
      stub(LicenseFinder.config).dependencies_yaml { "dependencies.yml" }
    end

    describe '.new' do
      subject { Dependency.new(attributes) }

      context "with known attributes" do
        it "should set the all of the attributes on the instance" do
          attributes.each do |key, value|
            subject.send("#{key}").should equal(value), "expected #{value.inspect} for #{key}, got #{subject.send("#{key}").inspect}"
          end
        end
      end

      context "with unknown attributes" do
        before do
          attributes['foo'] = 'bar'
        end
        it "should raise an exception" do
          expect { subject }.to raise_exception(NoMethodError)
        end
      end
    end

    describe "#approved" do
      it "should mark it as approved when the license is whitelisted" do
        dependency = Dependency.new('license' => 'MIT')
        dependency.approved.should == true
      end

      it "should not mark it as approved when the license is not whitelisted" do
        dependency = Dependency.new('license' => 'GPL')
        dependency.approved.should == false
      end

      it "should be settable" do
        dependency = Dependency.new
        dependency.approved = true
        dependency.approved.should == true
      end
    end

    describe '.new' do
      subject { Dependency.from_hash(attributes) }

      its(:name) { should == 'spec_name' }
      its(:version) { should == '2.1.3' }
      its(:license) { should == 'GPLv2' }
      its(:approved) { should == false }
      its(:notes) { should == "some notes" }
      its(:license_files) { should == %w(/Users/pivotal/foo/lic1 /Users/pivotal/bar/lic2) }
      its(:readme_files) { should == %w(/Users/pivotal/foo/Readme1 /Users/pivotal/bar/Readme2) }
      its(:source) { should == "bundle" }
      its(:bundler_groups) { should == ["test"] }

      describe "#as_yaml" do
        specify do
          subject.as_yaml.should == {
            'name' => 'spec_name',
            'version' => '2.1.3',
            'license' => 'GPLv2',
            'approved' => false,
            'source' => 'bundle',
            'homepage' => 'homepage',
            'license_url' => LicenseFinder::License::GPLv2.license_url,
            'notes' => 'some notes',
            'summary' => subject.summary,
            'description' => subject.description,
            'parents' => subject.parents,
            'children' => subject.children,
            'bundler_groups' => subject.bundler_groups,
            'license_files' => [
              '/Users/pivotal/foo/lic1',
              '/Users/pivotal/bar/lic2'
            ],
            'readme_files' => [
              '/Users/pivotal/foo/Readme1',
              '/Users/pivotal/bar/Readme2'
            ]
          }
        end
      end

      it 'should generate yaml' do
        yaml = YAML.load(subject.to_yaml)
        yaml.should == subject.as_yaml
      end
    end

    describe '.find_by_name' do
      subject { Dependency.find_by_name gem_name }
      let(:gem_name) { "foo" }

      before do
        Dependency.database.delete_all
      end

      context "when a gem with the provided name exists" do
        before do
          Dependency.new(
            'name' => gem_name,
            'version' => '0.0.1'
          ).save!
        end

        its(:name) { should == gem_name }
        its(:version) { should == '0.0.1' }
      end

      context "when no gem with the provided name exists" do
        it { should == nil }
      end
    end

    describe '#save!' do
      before do
        File.delete(LicenseFinder.config.dependencies_yaml) if File.exists?(LicenseFinder.config.dependencies_yaml)
      end

      it "should serialize its YAML representation out to the dependencies.yaml file" do
        dep = Dependency.new(attributes)
        dep.save!

        saved_dep = Dependency.find_by_name(dep.name)

        saved_dep.name.should == dep.name
        saved_dep.version.should == dep.version
        saved_dep.license.should == dep.license
        saved_dep.approved.should == dep.approved
        saved_dep.license_url.should == dep.license_url
        saved_dep.notes.should == dep.notes
        saved_dep.license_files.should == dep.license_files
        saved_dep.readme_files.should == dep.readme_files
        saved_dep.source.should == dep.source
        saved_dep.bundler_groups.should == dep.bundler_groups
        saved_dep.homepage.should == dep.homepage
        saved_dep.children.should == dep.children
        saved_dep.parents.should == dep.parents

        dep.version = "new version"
        dep.save!

        saved_dep = Dependency.find_by_name(dep.name)
        saved_dep.version.should == "new version"
      end
    end

    describe '#license_url' do
      context "class exists for license type" do
        it "should return the license url configured in the class" do
          Dependency.new('license' => "GPLv2").license_url.should == LicenseFinder::License::GPLv2.license_url
        end

        it "should handle differences in case" do
          Dependency.new('license' => "gplv2").license_url.should == LicenseFinder::License::GPLv2.license_url
        end
      end

      context "class does not exist for license type" do
        it "should return nil" do
          Dependency.new('license' => "FakeLicense").license_url.should be_nil
        end
      end
    end

    describe '#to_s' do
      let(:gem) do
        Dependency.new(
          'name' => 'test_gem',
          'version' => '1.0',
          'summary' => 'summary foo',
          'description' => 'description bar',
          'license' => "MIT"
        )
      end

      subject { gem.to_s.strip }

      it 'should generate text with the gem name, version, and license' do
        should == "test_gem, 1.0, MIT"
      end
    end

    describe '#to_html' do
      let(:dependency) { Dependency.new 'approved' => true }
      subject { dependency.to_html }

      context "when the dependency is approved" do
        it "should add an approved class to dependency's container" do
          should include %{class="approved"}
        end
      end

      context "when the dependency is not approved" do
        before { dependency.approved = false }

        it "should not add an approved class to he dependency's container" do
          should include %{class="unapproved"}
        end
      end

      context "when the gem has at least one bundler group" do
        before { dependency.bundler_groups = ["group"] }
        it "should show the bundler group(s) in parens" do
          should include "(group)"
        end
      end

      context "when the gem has no bundler groups" do
        before { dependency.bundler_groups = [] }

        it "should not show any parens or bundler group info" do
          should_not include "()"
        end

      end

      context "when the gem has at least one parent" do
        before { dependency.parents = [OpenStruct.new(:name => "foo parent")] }
        it "should include a parents section" do
          should include "Parents"
        end
      end

      context "when the gem has no parents" do
        it "should not include any parents section in the output" do
          should_not include "Parents"
        end
      end

      context "when the gem has at least one child" do
        before { dependency.children = [OpenStruct.new(:name => "foo child")] }

        it "should include a Children section" do
          should include "Children"
        end
      end

      context "when the gem has no children" do
        it "should not include any Children section in the output" do
          should_not include "Children"
        end
      end
    end

    describe '#source' do
      it "should default to nil" do
        Dependency.new.source.should be_nil
      end

      it "should be overridable" do
        Dependency.new("source" => "foo").source.should == "foo"
      end
    end

    describe '#merge' do
      subject do
        Dependency.new(
          'name' => 'foo',
          'license' => 'MIT',
          'version' => '0.0.1',
          'license_files' => "old license files",
          'readme_files' => "old readme files"
        )
      end

      let(:new_dep) do
        Dependency.new(
          'name' => 'foo',
          'license' => 'MIT',
          'version' => '0.0.2',
          'license_files' => "new license files",
          'readme_files' => "new readme files",
          'summary' => 'foo summary',
          'description' => 'awesome foo description!',
          'bundler_groups' => [1, 2, 3],
          'homepage' => "http://new.homepage"
        )
      end

      it 'should raise an error if the names do not match' do
        new_dep.name = 'bar'

        expect {
          subject.merge(new_dep)
        }.to raise_error
      end

      it 'should return the new version, license files, readme files, source, and homepage' do
        merged = subject.merge(new_dep)

        merged.version.should == '0.0.2'
        merged.license_files.should == new_dep.license_files
        merged.readme_files.should == new_dep.readme_files
        merged.source.should == new_dep.source
        merged.homepage.should == new_dep.homepage
      end

      it 'should return the new summary and description and bundle groups' do
        merged = subject.merge new_dep

        merged.summary.should == new_dep.summary
        merged.description.should == new_dep.description
        merged.bundler_groups.should == new_dep.bundler_groups
      end

      it 'should return the old notes' do
        subject.notes = 'old notes'
        new_dep.notes = 'new notes'

        merged = subject.merge(new_dep)

        merged.notes.should == 'old notes'
      end

      it 'should return the new license and approval if the license is different' do
        subject.license = "MIT"
        subject.approved = true

        new_dep.license = "GPLv2"
        new_dep.approved = false

        merged = subject.merge(new_dep)

        merged.license.should == "GPLv2"
        merged.approved.should == false
      end

      it 'should return the old license and approval if the new license is the same or "other"' do
        subject.approved = false
        subject.approved.should be_false
        new_dep.approved = true

        subject.merge(new_dep).approved.should == false

        new_dep.license = 'other'

        subject.merge(new_dep).approved.should == false
      end
    end

    describe '#approve!' do
      it "should update the yaml file to show the gem is approved" do
        gem = Dependency.new({name: "foo"})
        gem.approve!
        reloaded_gem = Dependency.find_by_name(gem.name)
        reloaded_gem.approved.should be_true
      end
    end
  end
end


