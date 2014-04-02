require 'spec_helper'

module LicenseFinder
  describe Maven do
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
        expect(described_class).to receive(:`).with(/mvn/)
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
        allow(File).to receive(:read).with("target/generated-resources/licenses.xml").and_return(license_xml)

        current_packages = Maven.current_packages

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

        allow(File).to receive(:read).with("target/generated-resources/licenses.xml").and_return(license_xml)

        MavenPackage.should_receive(:new).with("licenses" => [{"name" => "License 1"}, {"name" => "License 2"}])
        Maven.current_packages
      end

      it "handles no licenses" do
        license_xml = license_xml("""
          <dependency>
            <licenses>
            <!-- comment -->
            </licenses>
          </dependency>
        """)

        allow(File).to receive(:read).with("target/generated-resources/licenses.xml").and_return(license_xml)

        MavenPackage.should_receive(:new).with("licenses" => {})
        Maven.current_packages
      end
    end

    describe '.active?' do
      let(:package) { Pathname.new('pom.xml').expand_path }

      context 'with a pom.xml file' do
        before :each do
          allow(File).to receive(:exists?).with(package).and_return(true)
        end

        it 'returns true' do
          expect(Maven.active?).to eq(true)
        end
      end

      context 'without a pom.xml file' do
        before :each do
          allow(File).to receive(:exists?).with(package).and_return(false)
        end

        it 'returns false' do
          expect(Maven.active?).to eq(false)
        end
      end
    end
  end
end
