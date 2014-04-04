require 'spec_helper'

module LicenseFinder
  describe Reporter do
    describe "#write_reports" do
      subject { Reporter.write_reports }

      before do
        Dependency.stub(:all) { [double(:dep)] }

        MarkdownReport.stub(:of) { 'markdown report' }
        DetailedTextReport.stub(:of) { 'detailed csv report' }
        TextReport.stub(:of) { 'csv report' }
        HtmlReport.stub(:of) { 'html report' }
      end

      it "writes an html file" do
        subject
        LicenseFinder.config.artifacts.text_file.read.should == "csv report\n"
        LicenseFinder.config.artifacts.detailed_text_file.read.should == "detailed csv report\n"
        LicenseFinder.config.artifacts.markdown_file.read.should == "markdown report\n"
        LicenseFinder.config.artifacts.html_file.read.should == "html report\n"
      end

      it "deletes old dependencies.txt file" do
        fake_file =  double(:fake_file, :exist? => true)
        LicenseFinder.config.artifacts.stub(:legacy_text_file) { fake_file }
        fake_file.should_receive(:delete)
        subject
      end
    end
  end
end
