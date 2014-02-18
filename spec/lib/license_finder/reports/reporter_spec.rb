require 'spec_helper'

module LicenseFinder
  describe Reporter do
    describe "#write_reports" do
      subject { Reporter.write_reports }

      before do
        Dependency.stub(:all) { [double(:dep)] }

        MarkdownReport.stub_chain(:new, :to_s) { 'markdown report' }
        DetailedTextReport.stub_chain(:new, :to_s) { 'detailed csv report' }
        TextReport.stub_chain(:new, :to_s) { 'csv report' }
        HtmlReport.stub_chain(:new, :to_s) { 'html report' }
      end

      it "writes an html file" do
        subject
        LicenseFinder.config.artifacts.dependencies_text.read.should == "csv report\n"
        LicenseFinder.config.artifacts.dependencies_detailed_text.read.should == "detailed csv report\n"
        LicenseFinder.config.artifacts.dependencies_markdown.read.should == "markdown report\n"
        LicenseFinder.config.artifacts.dependencies_html.read.should == "html report\n"
      end

      it "deletes old dependencies.txt file" do
        fake_file =  double(:fake_file, :exist? => true)
        LicenseFinder.config.artifacts.stub(:legacy_dependencies_text) { fake_file }
        fake_file.should_receive(:delete)
        subject
      end
    end
  end
end
