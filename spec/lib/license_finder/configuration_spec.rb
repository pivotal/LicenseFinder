require "spec_helper"

module LicenseFinder
  describe Configuration do
    describe ".with_optional_saved_config" do
      it "should init and use saved config" do
        fake_project_dir = Pathname.new(__FILE__).dirname.join('..', '..', 'fixtures')

        subject = described_class.with_optional_saved_config({}, fake_project_dir)
        expect(subject.gradle_command).to eq('gradlew')
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

      it "has default" do
        subject = described_class.new(
          {gradle_command: nil},
          {"gradle_command" => nil}
        )
        expect(subject.gradle_command).to eq "gradle"
      end
    end

    describe "decisions_file" do
      it "prefers primary value" do
        subject = described_class.new(
          {decisions_file: "primary"},
          {"dependencies_file_dir" => "secondary"}
        )
        expect(subject.decisions_file.to_s).to eq "primary"
      end

      it "accepts saved value" do
        subject = described_class.new(
          {decisions_file: nil},
          {"dependencies_file_dir" => "secondary"}
        )
        expect(subject.decisions_file.to_s).to eq "secondary/dependency_decisions.yml"
      end

      it "has default" do
        subject = described_class.new(
          {decisions_file: nil},
          {"dependencies_file_dir" => nil}
        )
        expect(subject.decisions_file.to_s).to eq "doc/dependency_decisions.yml"
      end
    end
  end
end
