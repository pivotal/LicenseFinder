module LicenseFinder
  shared_examples "a PackageManager" do
    let(:all_pms) { fixture_path("all_pms") }
    it { expect(described_class.ancestors).to include PackageManager }
    it { expect(PackageManager.package_managers).to include described_class }

    context "logging" do
      it "logs when it checks for active-ness" do
        logger = double(:logger)
        expect(logger).to receive(:active)

        subject = described_class.new logger: logger, project_path: all_pms
        subject.active?
      end
    end

    describe '.active?' do
      it 'is true when package manager file exists' do
        expect(described_class.new(project_path: all_pms)).to be_active
      end

      it 'is false without a package manager file' do
        no_pms = fixture_path("not/a/path")
        expect(described_class.new(project_path: no_pms)).to_not be_active
      end
    end
  end
end
