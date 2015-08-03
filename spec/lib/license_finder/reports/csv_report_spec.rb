require 'spec_helper'

module LicenseFinder
  describe CsvReport do
    it "accepts a custom list of columns" do
      dep = Package.new('gem_a', '1.0')
      subject = described_class.new([dep], columns: %w[name version])
      expect(subject.to_s).to eq("gem_a,1.0\n")
    end

    it "understands many columns" do
      dep = Package.new('gem_a', '1.0', description: "A description", summary: "A summary", homepage: "http://homepage.example.com")
      dep.decide_on_license(License.find_by_name("MIT"))
      dep.decide_on_license(License.find_by_name("GPL"))
      dep.whitelisted!
      subject = described_class.new([dep], columns: %w[name version licenses approved summary description homepage])
      expect(subject.to_s).to eq("gem_a,1.0,\"MIT,GPL\",Approved,A summary,A description,http://homepage.example.com\n")
    end

    it "ignores unknown columns" do
      dep = Package.new('gem_a', '1.0')
      subject = described_class.new([dep], columns: %w[unknown])
      expect(subject.to_s).to eq("\n")
    end

    it "does not include columns that should only be in merged reports" do
      dep = Package.new('gem_a', '1.0')
      subject = described_class.new([dep], columns: %w[subproject_paths])
      expect(subject.to_s).to eq("\n")
    end
  end
end
