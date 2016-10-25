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

    def stub_license(hash = {})
      hash.each_key do |key|
        filename = project_path.join("Carthage/Checkouts/#{key}/LICENSE")
        allow(IO).to receive(:read)
          .with(filename)
          .and_return(hash[key])

        allow(File).to receive(:exists?)
          .with(filename)
          .and_return(true)
      end
    end

    def stub_license_md(hash = {})
      hash.each_key do |key|
        filename = project_path.join("Carthage/Checkouts/#{key}/LICENSE.md")
        allow(IO).to receive(:read)
          .with(filename)
          .and_return(hash[key])

        allow(File).to receive(:exists?)
          .with(filename)
          .and_return(true)
      end
    end

    def stub_license_markdown(hash = {})
      hash.each_key do |key|
        filename = project_path.join("Carthage/Checkouts/#{key}/LICENSE.markdown")
        allow(IO).to receive(:read)
          .with(filename)
          .and_return(hash[key])

        allow(File).to receive(:exists?)
          .with(filename)
          .and_return(true)
      end
    end

    before do
      allow(IO).to receive(:read).and_call_original
      allow(File).to receive(:exists?).and_return(false)
    end

    describe '.current_packages' do
      it 'lists all the current packages' do
        stub_resolved([
          'github "younata/Lepton" "92a21f46f12f2ec6a814aedc30a51e551d42a573"',
          'github "pivotal/PivotalCoreKit" "v0.3.4"',
          'git "https://example.com/dependency.git" "v0.1.0"'
        ])

        expect(carthage.current_packages.map { |p| [p.name, p.version] }).to eq [
          ['Lepton', '92a21f46f12f2ec6a814aedc30a51e551d42a573'],
          ['PivotalCoreKit', 'v0.3.4'],
          ['dependency', 'v0.1.0']
        ]
      end

      it 'passes the license text to the package' do
        stub_resolved(['github "pivotal/PivotalCoreKit" "v0.3.4"'])
        stub_license_md({'PivotalCoreKit' => 'The MIT License'})

        expect(carthage.current_packages.first.licenses.map(&:name)).to eq ['MIT']
      end

      it 'handles no licenses' do
        stub_resolved(['github "pivotal/PivotalCoreKit" "v0.3.4"'])

        expect(carthage.current_packages.first.licenses.map(&:name)).to eq ['unknown']
      end
    end
  end
end