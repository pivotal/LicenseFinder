require "spec_helper"

module LicenseFinder
  describe Configuration do
    describe ".ensure_default" do
      it "should init and use saved config" do
        expect(Configuration::Persistence).to receive(:init)
        allow(Configuration::Persistence).to receive(:get).and_return('whitelist' => ['Saved License'])

        expect(described_class.ensure_default.whitelist).to eq(['Saved License'])
      end
    end

    describe "#last_modified" do
      let(:time) { double :time }
      before do
        allow(Configuration::Persistence).to receive(:last_modified) { time }
      end

      it 'returns the last modified date of the config file' do
        expect(LicenseFinder::Configuration.new({}).last_modified).to eq time
      end
    end

    describe '.new' do
      it "should default missing attributes" do
        subject = described_class.new({})
        expect(subject.whitelist).to eq([])
        expect(subject.ignore_groups).to eq([])
        expect(subject.ignore_dependencies).to eq([])
        expect(subject.artifacts.dir).to eq(Pathname('./doc/'))
        expect(subject.gradle_command).to eq('gradle')
      end

      it "should default missing attributes even if they are saved as nils in the YAML file" do
        attributes = {
          "whitelist" => nil,
          "ignore_groups" => nil,
          "ignore_dependencies" => nil,
          "dependencies_file_dir" => nil,
          "project_name" => nil,
          "gradle_command" => nil
        }
        subject = described_class.new(attributes)
        expect(subject.whitelist).to eq([])
        expect(subject.ignore_groups).to eq([])
        expect(subject.ignore_dependencies).to eq([])
        expect(subject.artifacts.dir).to eq(Pathname('./doc/'))
        expect(subject.project_name).not_to be_nil
        expect(subject.gradle_command).to eq('gradle')
      end

      it "should set the all of the attributes on the instance" do
        attributes = {
          "whitelist" => %w{a whitelist},
          "ignore_groups" => %w{test development},
          "ignore_dependencies" => %w{bundler},
          "dependencies_file_dir" => "some/path",
          "project_name" => "my_app",
          "gradle_command" => "./gradlew"
        }
        subject = described_class.new(attributes)
        expect(subject.whitelist).to eq(%w{a whitelist})
        expect(subject.ignore_groups).to eq(%w{test development})
        expect(subject.ignore_dependencies).to eq(%w{bundler})
        expect(subject.artifacts.dir).to eq(Pathname("some/path"))
        expect(subject.project_name).to eq("my_app")
        expect(subject.gradle_command).to eq("./gradlew")
      end
    end

    describe "file paths" do
      it "should be relative to artifacts dir" do
        artifacts = described_class.new('dependencies_file_dir' => './elsewhere').artifacts
        expect(artifacts.dir).to eq(Pathname('./elsewhere'))
        expect(artifacts.legacy_yaml_file).to eq(Pathname('./elsewhere/dependencies.yml'))
        expect(artifacts.text_file).to eq(Pathname('./elsewhere/dependencies.csv'))
        expect(artifacts.html_file).to eq(Pathname('./elsewhere/dependencies.html'))
      end
    end

    describe "#database_uri" do
      it "should URI escape absolute path to dependencies_file_dir, even with spaces" do
        artifacts = described_class.new('dependencies_file_dir' => 'test path').artifacts
        expect(artifacts.database_uri).to match(%r{test%20path/dependencies\.db$})
      end
    end

    describe "#project_name" do
      it "should default to the directory name" do
        allow(Dir).to receive(:getwd).and_return("/path/to/a_project")
        expect(described_class.new({}).project_name).to eq("a_project")
      end
    end

    describe "#save" do
      def attributes # can't be a let... the caching causes polution
        {
          'whitelist' => ['my_gem'],
          'ignore_groups' => ['other_group', 'test'],
          'ignore_dependencies' => ['bundler'],
          'project_name' => "New Project Name",
          'dependencies_file_dir' => "./deps",
          'gradle_command' => './gradle'
        }
      end

      it "persists the configuration attributes" do
        expect(Configuration::Persistence).to receive(:set).with(attributes)
        described_class.new(attributes).save
      end

      it "doesn't persist duplicate entries" do
        config = described_class.new(attributes)
        config.whitelist << 'my_gem'
        config.ignore_groups << 'test'
        config.ignore_dependencies << 'bundler'

        expect(Configuration::Persistence).to receive(:set).with(attributes)
        config.save
      end
    end
  end

  describe Configuration::Artifacts do
    describe "#last_refreshed" do
      let(:database_modified_time) { 1 }
      let(:text_modified_time) { 2 }
      let(:detailed_text_modified_time) { 3 }
      let(:html_modified_time) { 4 }
      let(:markdown_modified_time) { 5 }

      before do
        allow(File).to receive(:mtime).with('./doc/dependencies.db') { database_modified_time }
        allow(File).to receive(:mtime).with('./doc/dependencies.csv') { text_modified_time }
        allow(File).to receive(:mtime).with('./doc/dependencies_detailed.csv') { detailed_text_modified_time }
        allow(File).to receive(:mtime).with('./doc/dependencies.html') { html_modified_time }
        allow(File).to receive(:mtime).with('./doc/dependencies.md') { markdown_modified_time }
      end

      it 'returns the earliest modified date of the config file' do
        expect(described_class.new(Pathname('./doc')).last_refreshed).to eq database_modified_time
      end
    end
  end

  describe Configuration::Persistence do
    describe ".get" do
      it "should use saved configuration" do
        file = double(:file,
                      :exist? => true,
                      :read => {'some' => 'config'}.to_yaml)
        allow(described_class).to receive(:file).and_return(file)

        expect(described_class.get).to eq({'some' => 'config'})
      end

      it "should not mind if config is not saved" do
        file = double(:file, :exist? => false)
        allow(described_class).to receive(:file).and_return(file)

        expect(file).not_to receive(:read)
        expect(described_class.get).to eq({})
      end
    end

    describe ".set" do
      let(:tmp_yml) { '.tmp.configuration_spec.yml' }

      after do
        File.delete(tmp_yml)
      end

      it "writes the configuration attributes to the yaml file" do
        allow(described_class).to receive(:file).and_return(Pathname.new(tmp_yml))

        described_class.set('some' => 'config')
        expect(described_class.get).to eq({'some' => 'config'})
      end
    end

    describe ".init" do
      it "initializes the config file" do
        file = double(:file, :exist? => false)
        allow(described_class).to receive(:file).and_return(file)

        expect(FileUtils).to receive(:cp).with(described_class.send(:file_template), file)
        described_class.init
      end

      it "does nothing if there is already a config file" do
        file = double(:file, :exist? => true)
        allow(described_class).to receive(:file).and_return(file)

        expect(FileUtils).not_to receive(:cp)
        described_class.init
      end
    end

    describe ".last_modified" do
      let(:time) { double :time }
      before do
        allow(File).to receive(:mtime).with('config/license_finder.yml') { time }
      end

      it "returns the last time the yml file was modified" do
        expect(described_class.last_modified).to eq time
      end
    end
  end
end
