require 'spec_helper'

module LicenseFinder
  describe CsvReport do
    it "accepts a custom list of columns" do
      dep = ManualPackage.new('gem_a', '1.0')
      subject = described_class.new([dep], columns: %w[name version])
      expect(subject.to_s).to eq("gem_a,1.0\n")
    end

    it "understands many columns" do
      dep = ManualPackage.new('gem_a', '1.0', description: "A description", summary: "A summary")
      dep.decide_on_license(License.find_by_name("MIT"))
      dep.decide_on_license(License.find_by_name("GPL"))
      dep.whitelisted!
      subject = described_class.new([dep], columns: %w[name version licenses approved summary description])
      expect(subject.to_s).to eq("gem_a,1.0,\"MIT,GPL\",Approved,A summary,A description\n")
    end

    it "ignores unknown columns" do
      dep = ManualPackage.new('gem_a', '1.0')
      subject = described_class.new([dep], columns: %w[unknown])
      expect(subject.to_s).to eq("\n")
    end
  end
end
