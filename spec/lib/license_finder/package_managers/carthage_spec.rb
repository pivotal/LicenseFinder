# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Carthage do
    let(:project_path) { fixture_path('all_pms') }
    let(:carthage) { Carthage.new(project_path: project_path) }
    it_behaves_like 'a PackageManager'

    def stub_resolved(frameworks)
      allow(IO).to receive(:read)
        .with(project_path.join('Cartfile.resolved'))
        .and_return(frameworks.join("\n"))
    end

    def stub_license_md(hash = {})
      hash.each_key do |key|
        license_pattern = project_path.join('Carthage', 'Checkouts', key, 'LICENSE*')
        filename = project_path.join('Carthage', 'Checkouts', key, 'LICENSE.md')
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

    describe '.current_packages' do
      context 'when carthage already ran and Cartfile.resolved exists' do
        before do
          allow(File).to receive(:exist?).and_return(true)
        end

        it 'lists all the current packages' do
          stub_resolved([
                          'github "younata/Lepton" "92a21f46f12f2ec6a814aedc30a51e551d42a573"',
                          'github "pivotal/PivotalCoreKit" "v0.3.4"',
                          'git "https://example.com/dependency.git" "v0.1.0"'
                        ])

          expect(carthage.current_packages.map { |p| [p.name, p.version] }).to eq [
            %w[Lepton 92a21f46f12f2ec6a814aedc30a51e551d42a573],
            ['PivotalCoreKit', 'v0.3.4'],
            ['dependency', 'v0.1.0']
          ]
        end

        it 'passes the license text to the package' do
          stub_resolved(['github "pivotal/PivotalCoreKit" "v0.3.4"'])
          stub_license_md('PivotalCoreKit' => 'The MIT License')

          expect(carthage.current_packages.first.licenses.map(&:name)).to eq ['MIT']
        end

        it 'handles no licenses' do
          stub_resolved(['github "pivotal/PivotalCoreKit" "v0.3.4"'])

          expect(carthage.current_packages.first.licenses.map(&:name)).to eq ['unknown']
        end
      end

      context 'when carthage did not run yet' do
        it 'raises an exception to explain the reason' do
          expect do
            carthage.current_packages.first.licenses.map(&:name)
          end.to raise_exception(Carthage::CarthageError)
        end
      end
    end
  end
end
