require 'spec_helper'

module LicenseFinder
  describe CocoaPods do
    let!(:cocoa_pods) { CocoaPods.new }
    before { allow(CocoaPods).to receive(:new) { cocoa_pods } }

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
      allow(YAML).to receive(:load_file).with(Pathname.new("Podfile.lock")).and_return("PODS" => pods)
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

    describe '.active?' do
      let(:package) { double(:package_file) }

      before do
        allow(cocoa_pods).to receive_messages(package_path: package)
      end

      it 'is true with a Podfile file' do
        allow(package).to receive_messages(:exist? => true)
        expect(cocoa_pods).to be_active
      end

      it 'is false without a Podfile file' do
        allow(package).to receive_messages(:exist? => false)
        expect(cocoa_pods).to_not be_active
      end
    end
  end
end
