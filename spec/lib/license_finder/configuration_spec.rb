require "spec_helper"

module LicenseFinder
  describe Configuration do
    describe ".ensure_default" do
      it "should init and use saved config" do
        Configuration::Persistence.should_receive(:init)
        Configuration::Persistence.stub(:get).and_return('whitelist' => ['Saved License'])

        described_class.ensure_default.whitelist.should == ['Saved License']
      end
    end

    describe '.new' do
      it "should default missing attributes" do
        subject = described_class.new({})
        subject.whitelist.should == []
        subject.ignore_groups.should == []
        subject.artifacts.dependencies_dir.should == Pathname('./doc/')
      end

      it "should default missing attributes even if they are saved as nils in the YAML file" do
        attributes = {
          "whitelist" => nil,
          "ignore_groups" => nil,
          "dependencies_file_dir" => nil,
          "project_name" => nil
        }
        subject = described_class.new(attributes)
        subject.whitelist.should == []
        subject.ignore_groups.should == []
        subject.artifacts.dependencies_dir.should == Pathname('./doc/')
        subject.project_name.should_not be_nil
      end

      it "should set the all of the attributes on the instance" do
        attributes = {
          "whitelist" => %w{a whitelist},
          "ignore_groups" => %w{test development},
          "dependencies_file_dir" => "some/path",
          "project_name" => "my_app"
        }
        subject = described_class.new(attributes)
        subject.whitelist.should == %w{a whitelist}
        subject.ignore_groups.should == %w{test development}
        subject.artifacts.dependencies_dir.should == Pathname("some/path")
        subject.project_name.should == "my_app"
      end
    end

    describe "file paths" do
      it "should be relative to dependencies_dir" do
        artifacts = described_class.new('dependencies_file_dir' => './elsewhere').artifacts
        artifacts.dependencies_dir.should == Pathname('./elsewhere')
        artifacts.legacy_dependencies_yaml.should == Pathname('./elsewhere/dependencies.yml')
        artifacts.dependencies_text.should == Pathname('./elsewhere/dependencies.csv')
        artifacts.dependencies_html.should == Pathname('./elsewhere/dependencies.html')
      end
    end

    describe "#database_uri" do
      it "should URI escape absolute path to dependencies_file_dir, even with spaces" do
        artifacts = described_class.new('dependencies_file_dir' => 'test path').artifacts
        artifacts.database_uri.should =~ %r{test%20path/dependencies\.db$}
      end
    end

    describe "#project_name" do
      it "should default to the directory name" do
        Dir.stub(:getwd).and_return("/path/to/a_project")
        described_class.new({}).project_name.should == "a_project"
      end
    end

    describe "whitelisted?" do
      context "short name whitelisted" do
        subject { described_class.new('whitelist' => ["Apache2"]) }

        it "should accept any of the licenses names" do
          subject.should be_whitelisted "Apache2"
          subject.should be_whitelisted "Apache 2.0"
          subject.should be_whitelisted "Apache-2.0"
        end

        it "should be case-insensitive" do
          subject.should be_whitelisted "apache2"
          subject.should be_whitelisted "apache 2.0"
          subject.should be_whitelisted "apache-2.0"
        end
      end
    end

    describe "#save" do
      def attributes # can't be a let... the caching causes polution
        {
          'whitelist' => ['my_gem'],
          'ignore_groups' => ['other_group', 'test'],
          'project_name' => "New Project Name",
          'dependencies_file_dir' => "./deps"
        }
      end

      it "persists the configuration attributes" do
        Configuration::Persistence.should_receive(:set).with(attributes)
        described_class.new(attributes).save
      end

      it "doesn't persist duplicate entries" do
        config = described_class.new(attributes)
        config.whitelist << 'my_gem'
        config.ignore_groups << 'test'

        Configuration::Persistence.should_receive(:set).with(attributes)
        config.save
      end
    end
  end

  describe Configuration::Persistence do
    describe ".get" do
      it "should use saved configuration" do
        file = double(:file,
                      :exist? => true,
                      :read => {'some' => 'config'}.to_yaml)
        described_class.stub(:file).and_return(file)

        described_class.get.should == {'some' => 'config'}
      end

      it "should not mind if config is not saved" do
        file = double(:file, :exist? => false)
        described_class.stub(:file).and_return(file)

        file.should_not_receive(:read)
        described_class.get.should == {}
      end
    end

    describe ".set" do
      let(:tmp_yml) { '.tmp.configuration_spec.yml' }

      after do
        File.delete(tmp_yml)
      end

      it "writes the configuration attributes to the yaml file" do
        described_class.stub(:file).and_return(Pathname.new(tmp_yml))

        described_class.set('some' => 'config')
        described_class.get.should == {'some' => 'config'}
      end
    end

    describe ".init" do
      it "initializes the config file" do
        file = double(:file, :exist? => false)
        described_class.stub(:file).and_return(file)

        FileUtils.should_receive(:cp).with(described_class.send(:file_template), file)
        described_class.init
      end

      it "does nothing if there is already a config file" do
        file = double(:file, :exist? => true)
        described_class.stub(:file).and_return(file)

        FileUtils.should_not_receive(:cp)
        described_class.init
      end
    end
  end
end
