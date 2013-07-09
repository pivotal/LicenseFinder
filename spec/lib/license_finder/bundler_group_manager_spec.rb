require "spec_helper"

module LicenseFinder
  describe BundlerGroupManager do
    let(:config) { Configuration.new }

    before do
      LicenseFinder.stub(:config).and_return config
      config.ignore_groups = ignore_groups
    end

    describe ".add_ignored_group" do
      describe "when the group is already ignored" do
        let(:ignore_groups) { ["test", "other_group"] }

        it "should not create a duplicate entry" do
          File.should_not_receive(:open)

          described_class.add_ignored_group("test")
        end
      end

      describe "when the group is not ignored" do
        let(:ignore_groups) { ["other_group"] }
        let(:whitelist) { ["my_gem"] }
        let(:tmp_yml) { '.tmp.bundler_group_manager_spec.yml' }

        before do
          Configuration.stub(:config_file_path).and_return(tmp_yml)
          config.whitelist = whitelist
        end

        after do
          File.delete(tmp_yml)
        end

        it "writes the ignore groups yaml config file" do
          described_class.add_ignored_group("test")

          yaml = YAML.load(File.read(tmp_yml))

          yaml["ignore_groups"].should include("other_group")
          yaml["ignore_groups"].should include("test")
        end

        it "persists the whitelist in the yaml config" do
          described_class.add_ignored_group("test")

          yaml = YAML.load(File.read(tmp_yml))

          yaml["whitelist"].should include("my_gem")
        end
      end
    end
  end
end
