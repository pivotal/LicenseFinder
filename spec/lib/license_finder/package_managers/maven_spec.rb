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
        expect(maven).to receive('`').with(/mvn/)
      end

      it 'lists all the current packages' do
        license_xml = license_xml("""
          <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.11</version>
            <licenses>
              <license>
                <name>Common Public License Version 1.0</name>
                <url>http://www.opensource.org/licenses/cpl1.0.txt</url>
              </license>
            </licenses>
          </dependency>
          <dependency>
            <groupId>org.hamcrest</groupId>
            <artifactId>hamcrest-core</artifactId>
            <version>1.3</version>
            <licenses>
              <license>
                <name>New BSD License</name>
                <url>http://www.opensource.org/licenses/bsd-license.php</url>
                <distribution>repo</distribution>
              </license>
            </licenses>
           </dependency>
        """)
        fake_file = double(:license_report, read: license_xml)
        allow(maven).to receive(:license_report).and_return(fake_file)

        current_packages = maven.current_packages

        expect(current_packages.size).to eq(2)
        expect(current_packages.first).to be_a(Package)
      end

      it "handles multiple licenses" do
        license_xml = license_xml("""
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
        """)

        fake_file = double(:license_report, read: license_xml)
        allow(maven).to receive(:license_report).and_return(fake_file)

        expect(MavenPackage).to receive(:new).with({"licenses" => [{"name" => "License 1"}, {"name" => "License 2"}]}, anything)
        maven.current_packages
      end

      it "handles no licenses" do
        license_xml = license_xml("""
          <dependency>
            <licenses>
            <!-- comment -->
            </licenses>
          </dependency>
        """)

        fake_file = double(:license_report, read: license_xml)
        allow(maven).to receive(:license_report).and_return(fake_file)

        expect(MavenPackage).to receive(:new).with({"licenses" => {}}, anything)
        maven.current_packages
      end
    end

    describe '.active?' do
      let(:package_path) { double(:package_file) }
      let(:maven) { Maven.new package_path: package_path }

      it 'is true with a pom.xml file' do
        allow(package_path).to receive(:exist?).and_return(true)
        expect(maven.active?).to eq(true)
      end

      it 'is false without a pom.xml file' do
        allow(package_path).to receive(:exist?).and_return(false)
        expect(maven.active?).to eq(false)
      end
    end
  end
end
