require 'spec_helper'

module LicenseFinder
  describe Maven do
    let(:maven) { Maven.new }
    it_behaves_like "a PackageManager"

    def license_xml(xml)
      <<-resp
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <licenseSummary>
          <dependencies>
            #{xml}
          </dependencies>
        </licenseSummary>
      resp
    end

    describe '.current_packages' do
      before do
        allow(maven).to receive('`').with(/mvn/)
      end

      it 'lists all the current packages' do
        license_xml = license_xml("
          <dependency>
            <artifactId>junit</artifactId>
            <version>4.11</version>
          </dependency>
          <dependency>
            <artifactId>hamcrest-core</artifactId>
            <version>1.3</version>
           </dependency>
        ")
        fake_file = double(:license_report, read: license_xml)
        allow(maven).to receive(:license_report).and_return(fake_file)

        expect(maven.current_packages.map { |p| [p.name, p.version] }).to eq [
          ["junit", "4.11"],
          ["hamcrest-core", "1.3"]
        ]
      end

      it "handles multiple licenses" do
        license_xml = license_xml("
          <dependency>
            <licenses>
              <license>
                <name>License 1</name>
              </license>
              <license>
                <name>License 2</name>
              </license>
            </licenses>
          </dependency>
        ")

        fake_file = double(:license_report, read: license_xml)
        allow(maven).to receive(:license_report).and_return(fake_file)

        expect(maven.current_packages.first.licenses.map(&:name)).to eq ['License 1', 'License 2']
      end

      it "handles no licenses" do
        license_xml = license_xml("
          <dependency>
          </dependency>
        ")

        fake_file = double(:license_report, read: license_xml)
        allow(maven).to receive(:license_report).and_return(fake_file)

        expect(maven.current_packages.first.licenses.map(&:name)).to eq ['unknown']
      end
    end
  end
end
