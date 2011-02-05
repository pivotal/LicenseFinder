require 'spec_helper'

describe LicenseFinder::LicenseFile do
  subject { LicenseFinder::LicenseFile.new('gem', 'gem/license/path') }

  context "ignoring text" do
    before do
      stub(IO).read { "file text" }
    end

    describe "#to_hash" do
      it "includes file path" do
        subject.to_hash['file_name'].should == 'license/path'
      end
      
      it "does not include file text by default" do
        subject.to_hash['text'].should be_nil
      end

      it "includes file text if requested" do
        subject.include_license_text = true
        subject.to_hash['text'].should == 'file text'
      end
      
      it "includes data about license" do
        subject.to_hash.should have_key 'body_type'
        subject.to_hash.should have_key 'header_type'
        subject.to_hash.should have_key 'disclaimer_of_liability'
      end
    end
  end

  context "with MIT like license" do
    before do
      stub(IO).read { File.read('spec/fixtures/MIT-LICENSE') }
    end

    its(:body_type) { should == 'mit' }
    its(:header_type) { should == 'mit' }
    its(:disclaimer_of_liability) { should == 'mit: THE AUTHORS OR COPYRIGHT HOLDERS' }
  end

  context "with another license" do
    before do
      stub(IO).read { "a non-standard license" }
    end

    its(:body_type) { should == 'other' }
    its(:header_type) { should == 'other' }
    its(:disclaimer_of_liability) { should == 'other' }
  end
  
  context "with variation in disclaimer of liability" do
    before do
      stub(IO).read { File.read('spec/fixtures/MIT-LICENSE-with-varied-disclaimer') }
    end

    its(:body_type) { should == 'mit' }
    its(:header_type) { should == 'mit' }
    its(:disclaimer_of_liability) { should == 'mit: THE AUTHORS' }
  end
end
