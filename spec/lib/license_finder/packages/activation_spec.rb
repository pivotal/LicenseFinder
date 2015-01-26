require 'spec_helper'

module LicenseFinder
  describe Activation do
    let(:package) { Package.new("p", nil) }
    let(:license) { License.find_by_name("l") }

    it "reports that a license has been activated for a package" do
      subject = Activation::Basic.new(package, license)
      expect(subject.package).to eq package
      expect(subject.license).to eq license
    end

    describe Activation::FromDecision do
      it "logs that it came from a decision" do
        activation = described_class.new(package, license)
        subject = capture_stdout { activation.log(Logger::Verbose.new) }
        expect(subject).to eq "LicenseFinder::Package: package p: found license 'l' from decision\n"
      end
    end

    describe Activation::FromSpec do
      it "logs that it came from a spec" do
        activation = described_class.new(package, license)
        subject = capture_stdout { activation.log(Logger::Verbose.new) }
        expect(subject).to eq "LicenseFinder::Package: package p: found license 'l' from spec\n"
      end
    end

    describe Activation::FromFiles do
      it "logs that it came from some files" do
        files = [double(:file, path: "x"), double(:file, path: "y")]
        activation = described_class.new(package, license, files)
        subject = capture_stdout { activation.log(Logger::Verbose.new) }
        expect(subject).to eq "LicenseFinder::Package: package p: found license 'l' from file 'x'\nLicenseFinder::Package: package p: found license 'l' from file 'y'\n"
      end
    end

    describe Activation::None do
      it "logs that no licenses could be found" do
        activation = described_class.new(package, license)
        subject = capture_stdout { activation.log(Logger::Verbose.new) }
        expect(subject).to eq "LicenseFinder::Package: package p: no licenses found\n"
      end
    end
  end
end
