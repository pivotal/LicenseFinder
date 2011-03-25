describe LicenseFinder do
  before(:each) do

  end

  it "should generate a yml file" do
    output = StringIO.new
    stub(File).open.yields(output)
    stub(File).exists? {true}
    LicenseFinder.to_yml
    output.string.should_not == ''
  end

  it 'should update an existing yml file' do
#    generate_yml_file
#    update_yml_file_with approved=true
#    regenerate_yml_file
#    assert approved=true
#    assert approved=false for newly added gem


  end
end