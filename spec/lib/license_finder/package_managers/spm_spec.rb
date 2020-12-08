
require 'spec_helper'

module LicenseFinder
  describe Spm do
    let(:project_path) { fixture_path('all_pms') }
    let(:spm) { Spm.new(project_path: project_path) }
    it_behaves_like 'a PackageManager'

    def stub_resolved(frameworks)
      allow(IO).to receive(:read)
                     .with(project_path.join('.build', 'workspace-state.json'))
                     .and_return(frameworks)
    end

    def stub_license_md(hash = {})
      hash.each_key do |key|
        license_pattern = project_path.join('.build', 'checkouts', key, 'LICENSE*')
        filename = project_path.join('.build', 'checkouts', key, 'LICENSE.md')
        allow(IO).to receive(:read)
                       .with(filename)
                       .and_return(hash[key])

        allow(File).to receive(:exist?)
                         .with(filename)
                         .and_return(true)

        allow(Dir).to receive(:glob)
                        .with(license_pattern, File::FNM_CASEFOLD)
                        .and_return([filename])
      end
    end

    before do
      allow(IO).to receive(:read).and_call_original
      allow(File).to receive(:exist?).and_return(false)
      allow(Dir).to receive(:glob).and_return([])
    end

    describe 'xcode packages' do
      context 'when SPM_DERIVED_DATA is provided as a relative path' do
        before do
          allow(ENV).to receive(:[]).with('SPM_DERIVED_DATA').and_return('./.build/')
        end

        it_behaves_like 'a PackageManager'
      end
    end

    describe 'current_packages' do
      context 'when SPM already ran and workspace-state.json exists' do
        before do
          allow(File).to receive(:exist?).and_return(true)
        end

        it 'lists all the current packages' do
          expect(spm.current_packages.map { |p| [p.name, p.version] }).to eq [
                                                                                    ['URLSessionDecodable', '0.1.0'],
                                                                                    ['Nimble', '6956ffbde4ea6aab94fd2e823c5ede95072feef2']
                                                                                  ]
        end

        it 'passes the license text to the package' do
          stub_license_md('URLSessionDecodable' => 'The MIT License')

          expect(spm.current_packages.first.licenses.map(&:name)).to eq ['MIT']
        end

        it 'handles no licenses' do
          expect(spm.current_packages.first.licenses.map(&:name)).to eq ['unknown']
        end
      end

      context 'when spm did not run yet' do
        it 'raises an exception to explain the reason' do
          expect do
            spm.current_packages.first.licenses.map(&:name)
          end.to raise_exception(Spm::SpmError)
        end
      end
    end
  end
end