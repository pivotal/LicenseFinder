require "spec_helper"

module LicenseFinder
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

    describe ".init!" do
      it "initializes the config file" do
        file = double(:file, :exist? => false)
        described_class.stub(:file).and_return(file)

        FileUtils.should_receive(:cp).with(described_class.send(:file_template), file)
        described_class.init!
      end

      it "does nothing if there is already a config file" do
        file = double(:file, :exist? => true)
        described_class.stub(:file).and_return(file)

        FileUtils.should_not_receive(:cp)
        described_class.init!
      end
    end
  end

  describe Configuration do
    let(:config) { described_class.new }

    let(:klass) { described_class }

    describe ".ensure_default" do
      it "should init and use saved config" do
        Configuration::Persistence.should_receive(:init!)
        Configuration::Persistence.stub(:get).and_return('whitelist' => ['Saved License'])

        klass.ensure_default.whitelist.should == ['Saved License']
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
        described_class.new(attributes.dup).save
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
end
