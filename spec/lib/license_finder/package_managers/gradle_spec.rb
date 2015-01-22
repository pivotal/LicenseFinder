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
        stub_license_report("""
          <dependency name='org.springframework:spring-aop:4.0.1.RELEASE'>
            <file>spring-aop-4.0.1.RELEASE.jar</file>
            <license name='The Apache Software License, Version 2.0' url='http://www.apache.org/licenses/LICENSE-2.0.txt' />
          </dependency>
          <dependency name='org.springframework:spring-core:4.0.1.RELEASE'>
            <file>spring-core-4.0.1.RELEASE.jar</file>
            <license name='The Apache Software License, Version 2.0' url='http://www.apache.org/licenses/LICENSE-2.0.txt' />
          </dependency>
        """)

        current_packages = gradle.current_packages

        expect(current_packages.size).to eq(2)
        expect(current_packages.first).to be_a(Package)
      end

      it "handles multiple licenses" do
        stub_license_report("""
          <dependency>
            <license name='License 1'/>
            <license name='License 2'/>
          </dependency>
        """)

        expect(GradlePackage).to receive(:new).with({"license" => [{"name" => "License 1"}, {"name" => "License 2"}]}, anything)
        gradle.current_packages
      end

      it "handles an empty list of licenses" do
        stub_license_report("""
          <dependency>
          </dependency>
        """)
        expect(GradlePackage).to receive(:new).with({}, anything)

        gradle.current_packages
      end
    end
  end
end
