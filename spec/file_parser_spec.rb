require 'spec_helper'

describe LicenseFinder::FileParser do
  subject { LicenseFinder::FileParser.new('root', 'root/nested/path') }

  context "ignoring text" do
    before do
      stub(IO).read { "file text" }
    end

    its(:file_path) { should == 'nested/path' }
    its(:file_name) { should == 'path' }
    its(:text) { should == 'file text' }
  end
end
