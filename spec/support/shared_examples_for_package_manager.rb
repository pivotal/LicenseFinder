# frozen_string_literal: true

module LicenseFinder
  shared_examples 'a PackageManager' do
    let(:all_pms) { fixture_path('all_pms') }

    it { expect(described_class.ancestors).to include PackageManager }
    it { expect(Scanner::PACKAGE_MANAGERS).to include described_class }

    describe '.active?' do
      before do
        allow_any_instance_of(described_class).to receive(:go_files_exist?).and_return(true)
      end

      it 'is true when package manager file exists' do
        expect(described_class.new(project_path: all_pms)).to be_active
      end

      it 'is false without a package manager file' do
        no_pms = fixture_path('not/a/path')
        expect(described_class.new(project_path: no_pms)).to_not be_active
      end
    end
  end
end
