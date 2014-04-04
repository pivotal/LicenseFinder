require 'spec_helper'

module LicenseFinder
  describe CocoaPods do
    def stub_acknowledgments(hash = {})
      plist_json = %{
        {
          "PreferenceSpecifiers": [
            {
              "FooterText": "#{hash[:license]}",
              "Title": "#{hash[:name]}"
            }
          ]
        }
      }

      expect(described_class).to receive(:`).with(/plutil/).and_return(plist_json)
    end

    def stub_lockfile(pods)
      allow(YAML).to receive(:load_file).with(Pathname.new("Podfile.lock").expand_path).and_return("PODS" => pods)
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

        current_packages = CocoaPods.current_packages

        expect(current_packages.size).to eq(3)
      end

      it "passes the license text to the package" do
        stub_lockfile(["Dependency Name (1.0)"])
        stub_acknowledgments({name: "Dependency Name", license: "License Text"})

        expect(CocoaPodsPackage).to receive(:new).with("Dependency Name", "1.0", "License Text")

        CocoaPods.current_packages
      end

      it "handles no licenses" do
        stub_lockfile(["Dependency Name (1.0)"])
        stub_acknowledgments

        expect(CocoaPodsPackage).to receive(:new).with("Dependency Name", "1.0", nil)

        CocoaPods.current_packages
      end
    end

    describe '.active?' do
      let(:package) { Pathname.new('Podfile').expand_path }

      context 'with a Podfile' do
        before :each do
          allow(File).to receive(:exists?).with(package).and_return(true)
        end

        it 'returns true' do
          expect(CocoaPods.active?).to eq(true)
        end
      end

      context 'without a Podfile file' do
        before :each do
          allow(File).to receive(:exists?).with(package).and_return(false)
        end

        it 'returns false' do
          expect(CocoaPods.active?).to eq(false)
        end
      end
    end
  end
end
