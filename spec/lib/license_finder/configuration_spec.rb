require "spec_helper"

module LicenseFinder
  describe Configuration do
    let(:config) { described_class.new }

    let(:klass) { described_class }

    describe '.new' do
      let(:attributes) do
        {
          "whitelist" => ["FooLicense", "BarLicense"],
          "ignore_groups" => [:test, :development],
          "dependencies_file_dir" => ".",
          "project_name" => "my_app"
        }
      end

      subject { klass.new(attributes) }

      context "with known attributes" do
        it "should set the all of the attributes on the instance" do
          subject.whitelist.should == attributes['whitelist']
          subject.ignore_groups.should == attributes['ignore_groups']
          subject.dependencies_dir.should == attributes['dependencies_file_dir']
          subject.project_name.should == attributes['project_name']
        end
      end
    end

    describe "#database_uri" do
      it "should URI escape absolute path the dependencies_file_dir" do
        config = described_class.new('dependencies_file_dir' => 'test path')
        config.database_uri.should =~ /test%20path\/dependencies\.db$/
      end
    end

    describe "#whitelist" do
      it "should default to an empty array" do
        klass.new.whitelist.should == []
      end
    end

    describe "#project_name" do
      let(:directory_name) { "test_dir" }

      before do
        Configuration.stub(:config_hash).and_return({})
        Dir.stub(:getwd).and_return("/path/to/#{directory_name}")
      end

      it "should default to the directory name" do
        klass.new.project_name.should == directory_name
      end
    end

    describe "whitelisted?" do
      context "canonical name whitelisted" do
        before { config.whitelist = [License::Apache2.names[rand(License::Apache2.names.count)]]}

        let(:possible_license_names) { License::Apache2.names }

        it "should return true if if the license is the canonical name, pretty name, or alternative name of the license" do
          possible_license_names.each do |name|
            config.whitelisted?(name).should be_true, "expected #{name} to be whitelisted, but wasn't."
          end
        end

        it "should be case-insensitive" do
          possible_license_names.map(&:downcase).each do |name|
            config.whitelisted?(name).should be_true, "expected #{name} to be whitelisted, but wasn't"
          end
        end
      end
    end

    describe "#save" do
      let(:tmp_yml) { '.tmp.configuration_spec.yml' }

      before do
        Configuration.stub(:config_file_path).and_return(tmp_yml)
        config.whitelist = ['my_gem']
        config.ignore_groups = ['other_group', 'test']
      end

      after do
        File.delete(tmp_yml)
      end

      it "writes the whitelist to the yaml file" do
        config.save

        yaml = YAML.load(File.read(tmp_yml))

        yaml["whitelist"].should include("my_gem")
      end

      it "writes the ignored bundler groups to the yaml file" do
        config.save

        yaml = YAML.load(File.read(tmp_yml))

        yaml["ignore_groups"].should include("other_group")
        yaml["ignore_groups"].should include("test")
      end

      it "doesn't write duplicate entries" do
        config.whitelist << 'my_gem'
        config.ignore_groups << 'test'

        config.save

        yaml = YAML.load(File.read(tmp_yml))

        yaml["whitelist"].count("my_gem").should == 1
        yaml["ignore_groups"].count("test").should == 1
      end
    end
  end
end
