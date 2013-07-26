require 'spec_helper'

module LicenseFinder
  describe Reporter do
    describe "#write_reports" do
      subject { Reporter.write_reports }

      before do
        Dependency.stub(:all) { [double(:dep)] }
        File.any_instance.stub(:puts)

        LicenseFinder.stub_chain(:config, :dependencies_html) { 'html_file_path' }
        LicenseFinder.stub_chain(:config, :dependencies_text) { 'text_file_path' }

        TextReport.stub_chain(:new, :to_s) { 'text report' }
        HtmlReport.stub_chain(:new, :to_s) { 'text report' }

        LicenseFinder.stub_chain(:config, :dependencies_legacy_text) { 'legacy_text_path' }
        File.stub(:exists?).with('legacy_text_path') { false }

        File.stub(:open).with('html_file_path', 'w+')
        File.stub(:open).with('text_file_path', 'w+')
      end

      it "writes an html file" do
        File.should_receive(:open).with('html_file_path', 'w+')
        File.should_receive(:open).with('text_file_path', 'w+')
        subject
      end

      it "deletes old dependencies.txt file" do
        File.stub(:exists?).with('legacy_text_path') { true }
        File.should_receive(:delete).with('legacy_text_path')
        subject
      end
    end
  end
end
