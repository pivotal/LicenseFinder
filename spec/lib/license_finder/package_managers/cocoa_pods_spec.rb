require 'spec_helper'

module LicenseFinder
  describe CocoaPods do
    let(:project_path) { fixture_path("all_pms") }
    let(:cocoa_pods) { CocoaPods.new(project_path: project_path) }
    it_behaves_like "a PackageManager"

    def stub_acknowledgments(hash = {})
      plist = {
        "PreferenceSpecifiers" => [
          {
            "FooterText" => hash[:license],
            "Title" => hash[:name]
          }
        ]
      }

      expect(cocoa_pods).to receive(:read_plist).and_return(plist)
    end

    def stub_lockfile(pods)
      allow(YAML).to receive(:load_file)
        .with(project_path.join("Podfile.lock"))
        .and_return("PODS" => pods)
    end

    describe '.current_packages' do
      it 'lists all the current packages' do
        stub_lockfile([
          { "ABTest (0.0.5)" => ["OpenUDID"] },
          "JSONKit (1.5pre)",
          "OpenUDID (1.0.0)"
        ])
        stub_acknowledgments

        expect(CocoaPodsPackage).to receive(:new).with("ABTest", "0.0.5", anything)
        expect(CocoaPodsPackage).to receive(:new).with("JSONKit", "1.5pre", anything)
        expect(CocoaPodsPackage).to receive(:new).with("OpenUDID", "1.0.0", anything)

        current_packages = cocoa_pods.current_packages

        expect(current_packages.size).to eq(3)
      end

      it "passes the license text to the package" do
        stub_lockfile(["Dependency Name (1.0)"])
        stub_acknowledgments({name: "Dependency Name", license: "License Text"})

        expect(CocoaPodsPackage).to receive(:new).with("Dependency Name", "1.0", "License Text")

        cocoa_pods.current_packages
      end

      it "handles no licenses" do
        stub_lockfile(["Dependency Name (1.0)"])
        stub_acknowledgments

        expect(CocoaPodsPackage).to receive(:new).with("Dependency Name", "1.0", nil)

        cocoa_pods.current_packages
      end
    end
  end
end
