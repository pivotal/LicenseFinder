require 'spec_helper'

describe LicenseFinder do
  before(:each) do

  end

  it "should generate a yml file" do
    stub(File).exists?('./config/dependencies.yml') {false}

    output = StringIO.new
    stub(File).open.yields(output)
    stub(File).exists?('./config') {true}
    stub(LicenseFinder::DependencyList).from_bundler.stub!.to_yaml {"output"}
    LicenseFinder.to_yml
    output.string.should == "output\n"
  end

  it 'should update an existing yml file' do
    stub(File).exists?('./config/dependencies.yml') {true}

    output = StringIO.new
    stub(File).open('./config/dependencies.yml').stub!.readlines {['existing yml']}
    stub(File).open('./config/dependencies.yml', 'w+').yields(output)
    
    stub(File).exists?('./config') {true}
    stub(LicenseFinder::DependencyList).from_yaml.stub!.merge.stub!.to_yaml {"output"}
    stub(LicenseFinder::DependencyList).from_bundler
    LicenseFinder.to_yml
    output.string.should == "output\n"
  end
end