require "spec_helper"

module LicenseFinder
  describe YmlToSql do
    let(:legacy_attributes) do
      {
        'name' => "spec_name",
        'version' => "2.1.3",
        'license' => "GPLv2",
        'license_url' => "www.license_url.org",
        'approved' => true,
        'summary' => "some summary",
        'description' => "some description",
        'homepage' => 'www.homepage.com',
        'children' => ["child1_name"],
        'parents' => ["parent1_name"],
        'bundler_groups' => [:test],
        'source' => source,

        'notes' => 'some notes',
        'license_files' => ['/Users/pivotal/foo/lic1', '/Users/pivotal/bar/lic2'],
      }
    end

    let(:source) { nil }

    describe ".needs_conversion?" do
      it "is true if the yml still exists" do
        yaml_file = double(:yaml_file, :exist? => true)
        allow(LicenseFinder.config.artifacts).to receive_messages(legacy_yaml_file: yaml_file)

        expect(described_class.needs_conversion?).to be_truthy
      end

      it "is false otherwise" do
        yaml_file = double(:yaml_file, :exist? => false)
        allow(LicenseFinder.config.artifacts).to receive_messages(legacy_yaml_file: yaml_file)

        expect(described_class.needs_conversion?).to be_falsey
      end
    end

    describe ".remove_yml" do
      it "removes the yml file" do
        yaml_file = double(:yaml_file)
        allow(LicenseFinder.config.artifacts).to receive_messages(legacy_yaml_file: yaml_file)

        expect(yaml_file).to receive(:delete)
        described_class.remove_yml
      end
    end

    describe '.convert_all' do
      before do
        (DB.tables - [:schema_migrations]).each { |table| DB[table].truncate }
      end

      describe "when dependency source is set to bundle" do
        let(:source) { "bundle" }

        it "sets manual to be false" do
          described_class.convert_all([legacy_attributes])

          saved_dep = described_class::Sql::Dependency.first
          expect(saved_dep).not_to be_added_manually
        end
      end

      describe "when dependency source is not set to bundle" do
        let(:source) { "" }

        it "sets manual to be true" do
          described_class.convert_all([legacy_attributes])

          saved_dep = described_class::Sql::Dependency.first
          expect(saved_dep).to be_added_manually
        end
      end

      it "persists all of the dependency's attributes" do
        described_class.convert_all([legacy_attributes])

        expect(described_class::Sql::Dependency.count).to eq(1)
        saved_dep = described_class::Sql::Dependency.first
        expect(saved_dep.name).to eq("spec_name")
        expect(saved_dep.version).to eq("2.1.3")
        expect(saved_dep.summary).to eq("some summary")
        expect(saved_dep.description).to eq("some description")
        expect(saved_dep.homepage).to eq("www.homepage.com")
        expect(saved_dep.manual_approval).to be
      end

      it "associates the license to the dependency" do
        described_class.convert_all([legacy_attributes])

        saved_dep = described_class::Sql::Dependency.first
        expect(saved_dep.license_names).to eq("GPLv2")
      end

      it "associates bundler groups" do
        described_class.convert_all([legacy_attributes])

        saved_dep = described_class::Sql::Dependency.first
        expect(saved_dep.bundler_groups.count).to eq(1)
        expect(saved_dep.bundler_groups.first.name).to eq('test')
      end

      it "associates children" do
        child_attrs = {
          'name' => 'child1_name',
          'version' => '0.0.1',
          'license' => 'unknown'
        }
        described_class.convert_all([legacy_attributes, child_attrs])

        expect(described_class::Sql::Dependency.count).to eq(2)
        saved_dep = described_class::Sql::Dependency.first(name: 'spec_name')
        expect(saved_dep.children.count).to eq(1)
        expect(saved_dep.children.first.name).to eq('child1_name')
      end
    end
  end
end
