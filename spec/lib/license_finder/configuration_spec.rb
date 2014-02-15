require "spec_helper"

module LicenseFinder
  describe Configuration do
    let(:config) { described_class.new }

    let(:klass) { described_class }

    describe ".ensure_default" do
      it "should handle a missing configuration file" do
        File.stub(:exists?).with('./config/license_finder.yml').and_return(false)
        File.should_not_receive(:read).with('./config/license_finder.yml')

        klass.ensure_default.whitelist.should == []
      end

      it "should use saved configuration" do
        File.stub(:exists?).with('./config/license_finder.yml').and_return(true)
        File.stub(:read).with('./config/license_finder.yml').and_return({'whitelist' => ['Apache']}.to_yaml)

        klass.ensure_default.whitelist.should == ['Apache']
      end
    end

    describe '.new' do
      let(:attributes) do
        {
          "whitelist" => ["FooLicense", "BarLicense"],
          "ignore_groups" => [:test, :development],
          "dependencies_file_dir" => ".",
          "project_name" => "my_app"
        }
      end

      it "should default missing attributes" do
        subject = klass.new
        subject.whitelist.should == []
        subject.ignore_groups.should == []
        subject.dependencies_dir.should == './doc/'
      end

      it "should set the all of the attributes on the instance" do
        subject = klass.new(attributes)
        subject.whitelist.should == attributes['whitelist']
        subject.ignore_groups.should == attributes['ignore_groups']
        subject.dependencies_dir.should == attributes['dependencies_file_dir']
        subject.project_name.should == attributes['project_name']
      end
    end

    describe "file paths" do
      it "should be relative to dependencies_dir" do
        config = klass.new('dependencies_file_dir' => './elsewhere')
        config.dependencies_dir.should == './elsewhere'
        config.dependencies_yaml.should == './elsewhere/dependencies.yml'
        config.dependencies_text.should == './elsewhere/dependencies.csv'
        config.dependencies_html.should == './elsewhere/dependencies.html'
      end
    end

    describe "#database_uri" do
      it "should URI escape absolute path the dependencies_file_dir" do
        config = described_class.new('dependencies_file_dir' => 'test path')
        config.database_uri.should =~ /test%20path\/dependencies\.db$/
      end
    end

    describe "#project_name" do
      let(:directory_name) { "test_dir" }

      before do
        Configuration.stub(:persisted_config_hash).and_return({})
        Dir.stub(:getwd).and_return("/path/to/#{directory_name}")
      end

      it "should default to the directory name" do
        klass.new.project_name.should == directory_name
      end
    end

    describe "whitelisted?" do
      context "canonical name whitelisted" do
        before { config.whitelist = ["Apache2"]}

        it "should return true if if the license is the canonical name, pretty name, or alternative name of the license" do
          config.should be_whitelisted "Apache2"
          config.should be_whitelisted "Apache 2.0"
          config.should be_whitelisted "Apache-2.0"
        end

        it "should be case-insensitive" do
          config.should be_whitelisted "apache2"
          config.should be_whitelisted "apache 2.0"
          config.should be_whitelisted "apache-2.0"
        end
      end
    end

    describe "#save" do
      let(:tmp_yml) { '.tmp.configuration_spec.yml' }
      let(:yaml) { YAML.load(File.read(tmp_yml)) }

      before do
        Configuration.stub(:config_file_path).and_return(tmp_yml)
        config.whitelist = ['my_gem']
        config.ignore_groups = ['other_group', 'test']
        config.project_name = "New Project Name"
        config.dependencies_dir = "./deps"
      end

      after do
        File.delete(tmp_yml)
      end

      describe "writes the configuration attributes to the yaml file" do
        before { config.save }

        it "writes the whitelist" do
          yaml["whitelist"].should include("my_gem")
        end

        it "writes the ignored bundler groups" do
          yaml["ignore_groups"].should include("other_group")
          yaml["ignore_groups"].should include("test")
        end

        it "writes the dependencies_dir" do
          yaml["dependencies_file_dir"].should eq("./deps")
        end

        it "writes the project name" do
          yaml["project_name"].should eq("New Project Name")
        end
      end

      it "doesn't write duplicate entries" do
        config.whitelist << 'my_gem'
        config.ignore_groups << 'test'

        config.save

        yaml["whitelist"].count("my_gem").should == 1
        yaml["ignore_groups"].count("test").should == 1
      end
    end
  end
end
