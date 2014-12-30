module LicenseFinder
  shared_examples "a PackageManager" do
    it { expect(described_class.ancestors).to include PackageManager }
    it { expect(PackageManager.package_managers).to include described_class }

    context "logging" do
      it "logs when it checks for active-ness" do
        logger = double(:logger)
        expect(logger).to receive(:active)

        subject = described_class.new logger: logger
        subject.active?
      end
    end
  end
end
