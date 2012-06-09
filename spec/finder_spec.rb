require 'spec_helper'

describe LicenseFinder::Finder do
  it "should generate a yml file and txt file" do
    stub(File).exists?('./config/license_finder.yml') {false}
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
    stub(File).exists?('./config/license_finder.yml') {false}
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

  it "should load a whitelist from license_finder.yml" do
    stub(File).exists?('./config/license_finder.yml') {true}
    stub(File).open('./config/license_finder.yml').stub!.readlines.stub!.join {"--- \nwhitelist: \n- MIT\n- Apache\nignore_groups: \n- test\n- development\n"}
    LicenseFinder::Finder.new.whitelist.should =~ ['MIT', 'Apache']
  end

  it "should load a ignore_groups list from license_finder.yml" do
    stub(File).exists?('./config/license_finder.yml') {true}
    stub(File).open('./config/license_finder.yml').stub!.readlines.stub!.join {"--- \nwhitelist: \n- MIT\n- Apache\nignore_groups: \n- test\n- development\n"}
    LicenseFinder::Finder.new.ignore_groups.should == [:test, :development]
  end

  it 'should allow the dependencies file directory to be configured' do
    stub(File).exists?('./config/license_finder.yml') {true}
    stub(File).open('./config/license_finder.yml').stub!.readlines.stub!.join {"--- \nwhitelist: \n- MIT\n- Apache\nignore_groups: \n- test\n- development\ndependencies_file_dir: './elsewhere'\n"}
    finder = LicenseFinder::Finder.new
    finder.dependencies_dir.should == './elsewhere'
    finder.dependencies_yaml.should == './elsewhere/dependencies.yml'
    finder.dependencies_text.should == './elsewhere/dependencies.txt'
  end
end
