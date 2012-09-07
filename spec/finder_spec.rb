require 'spec_helper'

describe LicenseFinder::Finder do
  before do
    config = stub(LicenseFinder).config.stub!
    config.dependencies_yaml { './dependencies.yml' }
    config.dependencies_text { './dependencies.txt' }
  end

  it "should generate a yml file and txt file" do
    stub(File).exists?('./dependencies.yml') {false}

    yml_output = StringIO.new
    txt_output = StringIO.new
    stub(File).open('./dependencies.yml', 'w+').yields(yml_output)
    stub(File).open('./dependencies.txt', 'w+').yields(txt_output)
    stub(LicenseFinder::DependencyList).from_bundler.stub!.to_yaml {"output"}
    LicenseFinder::Finder.new.write_files
    yml_output.string.should == "output\n"
  end

  it 'should update an existing yml file' do
    stub(File).exists?('./dependencies.yml') {true}

    yml_output = StringIO.new
    txt_output = StringIO.new
    stub(File).open('./dependencies.yml').stub!.readlines {['existing yml']}
    stub(File).open('./dependencies.yml', 'w+').yields(yml_output)
    stub(File).open('./dependencies.txt', 'w+').yields(txt_output)

    stub(LicenseFinder::DependencyList).from_yaml.stub!.merge.stub!.to_yaml {"output"}
    stub(LicenseFinder::DependencyList).from_bundler
    LicenseFinder::Finder.new.write_files
    yml_output.string.should == "output\n"
  end
end
