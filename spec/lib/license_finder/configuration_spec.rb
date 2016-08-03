require "spec_helper"

module LicenseFinder
  describe Configuration do
    describe ".with_optional_saved_config" do
      it "should init and use saved config" do
        subject = described_class.with_optional_saved_config({project_path: fixture_path(".")})
        expect(subject.gradle_command).to eq('gradlew')
      end

      it "prepends the project_path to the config file path" do
        subject = described_class.with_optional_saved_config({project_path: "other_directory"})
        expect(subject.send(:saved_config)).to eq({})
      end
    end

    describe "#valid_project_path?" do
      it "returns false when the path does not exist" do
        subject = described_class.with_optional_saved_config({project_path: '/path/that/does/not/exist'})
        expect(subject.valid_project_path?).to be(false)
      end

      it "returns true when the path exists" do
        subject = described_class.with_optional_saved_config({project_path: '/'})
        expect(subject.valid_project_path?).to be(true)
      end

      it "returns true if the path is not provided" do
        subject = described_class.with_optional_saved_config({})
        expect(subject.valid_project_path?).to be(true)
      end
    end

    describe "gradle_command" do
      it "prefers primary value" do
        subject = described_class.new(
          {gradle_command: "primary"},
          {"gradle_command" => "secondary"}
        )
        expect(subject.gradle_command).to eq "primary"
      end

      it "accepts saved value" do
        subject = described_class.new(
          {gradle_command: nil},
          {"gradle_command" => "secondary"}
        )
        expect(subject.gradle_command).to eq "secondary"
      end
    end

    describe "decisions_file" do
      it "prefers primary value" do
        subject = described_class.new(
          {decisions_file: "primary"},
          {"decisions_file" => "secondary"}
        )
        expect(subject.decisions_file_path.to_s).to end_with "primary"
      end

      it "accepts saved value" do
        subject = described_class.new(
          {decisions_file: nil},
          {"decisions_file" => "secondary"}
        )
        expect(subject.decisions_file_path.to_s).to end_with "secondary"
      end

      it "has default" do
        subject = described_class.new(
          {decisions_file: nil},
          {"decisions_file" => nil}
        )
        expect(subject.decisions_file_path.to_s).to end_with "doc/dependency_decisions.yml"
      end

      it "prepends project path to default path if project_path option is set" do
        subject = described_class.new({project_path: "magic_path"}, {})
        expect(subject.decisions_file_path.to_s).to end_with "magic_path/doc/dependency_decisions.yml"
      end

      it "prepends project path to provided value" do
        subject = described_class.new({decisions_file: "primary",
            project_path: "magic_path"},
            {"decisions_file" => "secondary"}
        )
        expect(subject.decisions_file_path.to_s).to end_with "magic_path/primary"
      end
    end

    describe "rebar_deps_dir" do
      it "has default" do
        subject = described_class.new(
            {rebar_deps_dir: nil},
            {"rebar_deps_dir" => nil}
        )
        expect(subject.rebar_deps_dir.to_s).to end_with "deps"
      end

      it "prepends project path to default path if project_path option is set" do
        subject = described_class.new({project_path: "magic_path"}, {})
        expect(subject.rebar_deps_dir.to_s).to end_with "magic_path/deps"
      end

      it "prepends project path to provided value" do
        subject = described_class.new(
            {rebar_deps_dir: "primary",
             project_path: "magic_path"},
            {"rebar_deps_dir" => "secondary"}
        )
        expect(subject.rebar_deps_dir.to_s).to end_with "magic_path/primary"
      end
    end
  end
end
