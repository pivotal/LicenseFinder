require "spec_helper"

module LicenseFinder
  describe Configuration do
    describe ".ensure_default" do
      it "should init and use saved config" do
        expect(Configuration::Persistence).to receive(:init)
        allow(Configuration::Persistence).to receive(:get).and_return('dependencies_file_dir' => 'some/path')

        expect(described_class.ensure_default.artifacts.dir.to_s).to eq('some/path')
      end
    end

    describe '.new' do
      it "should default missing attributes" do
        subject = described_class.new({})
        expect(subject.artifacts.dir).to eq(Pathname('./doc/'))
      end

      it "should default missing attributes even if they are saved as nils in the YAML file" do
        attributes = {
          "dependencies_file_dir" => nil
        }
        subject = described_class.new(attributes)
        expect(subject.artifacts.dir).to eq(Pathname('./doc/'))
      end

      it "should set the all of the attributes on the instance" do
        attributes = {
          "dependencies_file_dir" => "some/path"
        }
        subject = described_class.new(attributes)
        expect(subject.artifacts.dir).to eq(Pathname("some/path"))
      end
    end

    describe "file paths" do
      it "should be relative to artifacts dir" do
        artifacts = described_class.new('dependencies_file_dir' => './elsewhere').artifacts
        expect(artifacts.dir).to eq(Pathname('./elsewhere'))
        expect(artifacts.decisions_file).to eq(Pathname('./elsewhere/dependency_decisions.yml'))
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
  end
end
