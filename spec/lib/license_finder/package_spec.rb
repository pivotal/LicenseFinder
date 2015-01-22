require 'spec_helper'

module LicenseFinder
  describe Package do
    subject do
      described_class.new(
        "a package",
        "1.3.1",
        summary: "a summary",
        description: "a description",
        homepage: "a homepage",
        groups: %w[dev test],
        children: %w[child-1 child2],
        install_path: "some/package/path",
        spec_licenses: %w[MIT GPL]
      )
    end

    it_behaves_like "a Package"

    its(:name) { should == "a package" }
    its(:version) { should == "1.3.1" }
    its(:summary) { should == "a summary" }
    its(:description) { should == "a description" }
    its(:homepage) { should == "a homepage" }
    its(:groups) { should == %w[dev test] }
    its(:children) { should == %w[child-1 child2] }
    its(:install_path) { should eq "some/package/path" }

    it "has defaults" do
      subject = described_class.new(nil, nil)
      expect(subject.name).to be_nil
      expect(subject.version).to be_nil
      expect(subject.summary).to eq ""
      expect(subject.description).to eq ""
      expect(subject.homepage).to eq ""
      expect(subject.groups).to eq []
      expect(subject.children).to eq []
      expect(subject.install_path).to be_nil
      expect(subject.license_names_from_spec).to eq []
      expect(subject.licenses.map(&:name)).to eq ['unknown']
    end

    describe '#licenses' do
      def stub_license_files(*license_names)
        license_files = license_names.map do |license_name|
          double(:file, license: License.find_by_name(license_name), path: "some/path")
        end
        allow(LicenseFiles).to receive(:find).
          with("some/package/path").and_return(license_files)
      end

      it "are not required" do
        subject = described_class.new(nil, nil)
        expect(subject.licenses.map(&:name)).to eq ['unknown']
      end

      describe "decided by user" do
        it "returns all decided licenses" do
          subject = described_class.new(nil, nil)
          subject.decide_on_license(License.find_by_name("MIT"))
          subject.decide_on_license(License.find_by_name("GPL"))
          expect(subject.licenses.map(&:name)).to match_array ["MIT", "GPL"]
        end

        it "de-duplicates across license aliases" do
          subject = described_class.new(nil, nil)
          subject.decide_on_license(License.find_by_name("MIT"))
          subject.decide_on_license(License.find_by_name("Expat"))
          expect(subject.licenses.map(&:name)).to eq ["MIT"]
        end

        it "trumps licenses from the spec" do
          subject = described_class.new(nil, nil, spec_licenses: ["GPL"])
          subject.decide_on_license(License.find_by_name("MIT"))
          expect(subject.licenses.map(&:name)).to eq ["MIT"]
        end

        it "trumps licenses from the install path" do
          stub_license_files 'Detected License'
          subject = described_class.new(nil, nil, install_path: "some/package/path")
          subject.decide_on_license(License.find_by_name("MIT"))
          expect(subject.licenses.map(&:name)).to eq ["MIT"]
        end
      end

      describe "from the spec" do
        it "converts the names to licenses" do
          subject = described_class.new(nil, nil, spec_licenses: ["MIT", "GPL"])
          expect(subject.licenses.map(&:name)).to match_array ["MIT", "GPL"]
        end

        it "de-duplicates across license aliases" do
          subject = described_class.new(nil, nil, spec_licenses: ["MIT", "Expat"])
          expect(subject.licenses.map(&:name)).to eq ["MIT"]
        end

        it "trumps licenses from the install path" do
          stub_license_files 'Detected License'
          subject = described_class.new(nil, nil, spec_licenses: ["MIT"], install_path: "some/package/path")
          expect(subject.licenses.map(&:name)).to eq ["MIT"]
        end
      end

      describe "from the install path" do
        it "uses the licenses reported by files in the install path" do
          stub_license_files 'MIT', 'GPL'
          subject = described_class.new(nil, nil, install_path: "some/package/path")
          expect(subject.licenses.map(&:name)).to eq ["MIT", "GPL"]
        end

        it "de-duplicates across license aliases" do
          stub_license_files 'MIT', 'Expat'
          subject = described_class.new(nil, nil, install_path: "some/package/path")
          expect(subject.licenses.map(&:name)).to eq ["MIT"]
        end
      end
    end
  end
end

