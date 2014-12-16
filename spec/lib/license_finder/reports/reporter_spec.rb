require 'spec_helper'

module LicenseFinder
  describe Reporter do
    describe "#write_reports" do
      subject { Reporter.write_reports(double(:dep)) }

      before do
        allow(MarkdownReport).to receive(:of) { 'markdown report' }
        allow(DetailedTextReport).to receive(:of) { 'detailed csv report' }
        allow(TextReport).to receive(:of) { 'csv report' }
        allow(HtmlReport).to receive(:of) { 'html report' }
      end

      it "writes an html file" do
        subject
        expect(LicenseFinder.config.artifacts.text_file.read).to eq("csv report\n")
        expect(LicenseFinder.config.artifacts.detailed_text_file.read).to eq("detailed csv report\n")
        expect(LicenseFinder.config.artifacts.markdown_file.read).to eq("markdown report\n")
        expect(LicenseFinder.config.artifacts.html_file.read).to eq("html report\n")
      end

      it "deletes old dependencies.txt file" do
        fake_file =  double(:fake_file, :exist? => true)
        allow(LicenseFinder.config.artifacts).to receive(:legacy_text_file) { fake_file }
        expect(fake_file).to receive(:delete)
        subject
      end
    end
  end
end
