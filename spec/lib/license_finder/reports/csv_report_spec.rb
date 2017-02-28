require 'spec_helper'

module LicenseFinder
  describe CsvReport do
    it "accepts a custom list of columns" do
      dep = Package.new('gem_a', '1.0')
      subject = described_class.new([dep], columns: %w[name version])
      expect(subject.to_s).to eq("gem_a,1.0\n")
    end

    it "understands many columns" do
      dep = Package.new('gem_a', '1.0', authors: "the authors", description: "A description", summary: "A summary", homepage: "http://homepage.example.com")
      dep.decide_on_license(License.find_by_name("MIT"))
      dep.decide_on_license(License.find_by_name("GPL"))
      dep.whitelisted!
      subject = described_class.new([dep], columns: %w[name version authors licenses approved summary description homepage])
      expect(subject.to_s).to eq("gem_a,1.0,the authors,\"MIT,GPL\",Approved,A summary,A description,http://homepage.example.com\n")
    end

    it "ignores unknown columns" do
      dep = Package.new('gem_a', '1.0')
      subject = described_class.new([dep], columns: %w[unknown])
      expect(subject.to_s).to eq("\n")
    end

    it 'supports install_path column' do
      dep = Package.new('gem_a', '1.0', install_path: '/tmp/gems/gem_a-1.0')
      subject = described_class.new([dep], columns: %w[name version install_path])
      expect(subject.to_s).to eq("gem_a,1.0,/tmp/gems/gem_a-1.0\n")
    end

    it 'supports package_manager column' do
      dep = NugetPackage.new('gem_a', '1.0')
      subject = described_class.new([dep], columns: %w[name version package_manager])
      expect(subject.to_s).to eq("gem_a,1.0,Nuget\n")
    end

    it "does not include columns that should only be in merged reports" do
      dep = Package.new('gem_a', '1.0')
      subject = described_class.new([dep], columns: %w[subproject_paths])
      expect(subject.to_s).to eq("\n")
    end

    context "when no groups are specified" do
      let( :dep ) { Package.new('gem_a', '1.0') }
      subject { described_class.new([dep], columns: %w[name version groups]) }

      it 'supports a groups column' do
        expect(subject.to_s).to eq("gem_a,1.0,\"\"\n")
      end
    end

    context "when some groups are specified" do
      let( :dep ) { Package.new('gem_a', '1.0', groups: %w[development production]) }
      subject { described_class.new([dep], columns: %w[name version groups]) }

      it 'supports a groups column' do
        expect(subject.to_s).to eq("gem_a,1.0,\"development,production\"\n")
      end
    end

    context "when no parents are specified" do
      let( :dep ) { Package.new('gem_a', '1.0') }
      subject { described_class.new([dep], columns: %w[name version parents]) }

      it 'supports a parents column' do
        expect(subject.to_s).to eq("gem_a,1.0,\"\"\n")
      end
    end

    context "when some parents are specified" do
      dep = Package.new('gem_a', '1.0')
      dep.parents << "gem_b"
      dep.parents << "gem_c"
      subject { described_class.new([dep], columns: %w[name version parents]) }

      it 'supports a parents column' do
        expect(subject.to_s).to eq("gem_a,1.0,\"gem_b,gem_c\"\n")
      end
    end

    context "when no children are specified" do
      let( :dep ) { Package.new('gem_a', '1.0') }
      subject { described_class.new([dep], columns: %w[name version children]) }

      it 'supports the children column' do
        expect(subject.to_s).to eq("gem_a,1.0,\"\"\n")
      end
    end

    context "when some children are specified" do
      let( :dep ) { Package.new('gem_a', '1.0', children: %w[gem_b gem_c]) }
      subject { described_class.new([dep], columns: %w[name version children]) }

      it 'supports the children column' do
        expect(subject.to_s).to eq("gem_a,1.0,\"gem_b,gem_c\"\n")
      end
    end

  end
end
