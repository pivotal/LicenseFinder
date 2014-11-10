module LicenseFinder
  shared_examples "a Package" do
    context "the interface required by PackageSave" do
      it { expect { subject.name }.to_not raise_error }
      it { expect { subject.version }.to_not raise_error }
      it { expect { subject.summary }.to_not raise_error }
      it { expect { subject.description }.to_not raise_error }
      it { expect { subject.homepage }.to_not raise_error }
      it { expect { subject.groups }.to_not raise_error }
      it { expect { subject.children }.to_not raise_error }
      it { expect { subject.licenses }.to_not raise_error }
    end

    context "logging" do
      let!(:logger) { Logger::Quiet.new }
      before { allow(Logger::Default).to receive(:new) { logger } }

      it "logs licenses found in specs" do
        license_short_name = "foo"
        license_pretty_name = "pretty foo"
        license = double(:license, name: license_pretty_name)

        allow(subject).to receive(:license_names_from_spec).and_return([license_short_name])
        allow(License).to receive(:find_by_name).with(license_short_name) { license }

        expect(logger).to receive(:license).with(anything, subject.name, license_pretty_name, "from spec")

        subject.licenses_from_spec
      end

      it "logs licenses found in files" do
        license_short_name = "foo"
        license_pretty_name = "pretty foo"
        license_path = "/path/to/license"
        license = double(:license, name: license_pretty_name)
        license_file = double(:license_file, license: license, path: license_path)

        allow(subject).to receive(:license_files) { [license_file] }

        expect(logger).to receive(:license).with(anything, subject.name, license_pretty_name, "from file '#{license_path}'")

        subject.licenses_from_files
      end
    end
  end
end
