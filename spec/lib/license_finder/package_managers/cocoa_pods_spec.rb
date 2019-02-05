# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe CocoaPods do
    let(:project_path) { fixture_path('all_pms') }
    let(:cocoa_pods) { CocoaPods.new(project_path: project_path) }
    it_behaves_like 'a PackageManager'

    def stub_acknowledgments(hash = {})
      plist = {
        'PreferenceSpecifiers' => [
          {
            'FooterText' => hash[:license],
            'Title' => hash[:name]
          }
        ]
      }

      expect(cocoa_pods).to receive(:acknowledgements_path).and_return('some.plist')
      expect(cocoa_pods).to receive(:read_plist).and_return(plist)
    end

    def stub_lockfile(pods)
      allow(YAML).to receive(:load_file)
        .with(project_path.join('Podfile.lock'))
        .and_return('PODS' => pods)
    end

    describe '.current_packages' do
      it 'lists all the current packages' do
        stub_lockfile([
                        { 'ABTest (0.0.5)' => ['OpenUDID'] },
                        'JSONKit (1.5pre)',
                        'OpenUDID (1.0.0)'
                      ])
        stub_acknowledgments

        expect(cocoa_pods.current_packages.map { |p| [p.name, p.version] }).to eq [
          ['ABTest', '0.0.5'],
          ['JSONKit', '1.5pre'],
          ['OpenUDID', '1.0.0']
        ]
      end

      it 'passes the license text to the package' do
        stub_lockfile(['Dependency Name (1.0)'])
        stub_acknowledgments(name: 'Dependency Name', license: 'The MIT License')

        expect(cocoa_pods.current_packages.first.licenses.map(&:name)).to eq ['MIT']
      end

      it 'handles no licenses' do
        stub_lockfile(['Dependency Name (1.0)'])
        stub_acknowledgments

        expect(cocoa_pods.current_packages.first.licenses.map(&:name)).to eq ['unknown']
      end

      it 'raises when no acknowledgements file is found' do
        stub_lockfile(['Dependency Name (1.0)'])

        expect { cocoa_pods.current_packages }.to raise_error("Found a Podfile but no Pods directory in \
#{project_path}. Try running pod install before running license_finder.")
      end
    end
  end
end
