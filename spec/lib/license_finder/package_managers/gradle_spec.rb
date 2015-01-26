require 'spec_helper'

module LicenseFinder
  describe Gradle do
    let(:gradle) { Gradle.new }
    it_behaves_like "a PackageManager"

    def license_xml(xml)
      <<-resp
        <dependencies>
          #{xml}
        </dependencies>
      resp
    end

    def stub_license_report(dependencies, package_manager = gradle)
      license_xml = license_xml(dependencies)
      fake_file = double(:license_report, read: license_xml)
      allow(package_manager).to receive(:license_report).and_return(fake_file)
    end

    describe '.current_packages' do
      before do
        allow(gradle).to receive('`').with(/gradle downloadLicenses/)
      end

      it "uses custom gradle command, if provided" do
        gradle = Gradle.new(gradle_command: "gradlefoo")
        stub_license_report("", gradle)
        expect(gradle).to receive('`').with(/gradlefoo downloadLicenses/)
        gradle.current_packages
      end

      it 'lists all the current packages' do
        stub_license_report("
          <dependency name='org.springframework:spring-aop:4.0.1.RELEASE'>
          </dependency>
          <dependency name='org.springframework:spring-core:4.0.1.RELEASE'>
          </dependency>
        ")

        expect(gradle.current_packages.map(&:name)).to eq ['spring-aop', 'spring-core']
      end

      it "handles multiple licenses" do
        stub_license_report("
          <dependency name=''>
            <license name='License 1'/>
            <license name='License 2'/>
          </dependency>
        ")

        expect(gradle.current_packages.first.licenses.map(&:name)).to eq ["License 1", "License 2"]
      end

      it "handles an empty list of licenses" do
        stub_license_report("
          <dependency name=''>
          </dependency>
        ")

        expect(gradle.current_packages.first.licenses.map(&:name)).to eq ['unknown']
      end
    end
  end
end
