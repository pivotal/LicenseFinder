require 'spec_helper'

module LicenseFinder
  describe Gradle do
    def license_xml(xml)
      <<-resp
        <dependencies>
          #{xml}
        </dependencies>
      resp
    end

    describe '.current_packages' do
      before do
        expect(described_class).to receive(:`).with(/gradle downloadLicenses/)
      end

      it 'lists all the current packages' do
        license_xml = license_xml("""
          <dependency name='org.springframework:spring-aop:4.0.1.RELEASE'>
            <file>spring-aop-4.0.1.RELEASE.jar</file>
            <license name='The Apache Software License, Version 2.0' url='http://www.apache.org/licenses/LICENSE-2.0.txt' />
          </dependency>
          <dependency name='org.springframework:spring-core:4.0.1.RELEASE'>
            <file>spring-core-4.0.1.RELEASE.jar</file>
            <license name='The Apache Software License, Version 2.0' url='http://www.apache.org/licenses/LICENSE-2.0.txt' />
          </dependency>
        """)
        fake_file = double(:license_report, read: license_xml)
        allow(Gradle).to receive(:license_report).and_return(fake_file)

        current_packages = described_class.current_packages

        expect(current_packages.size).to eq(2)
        expect(current_packages.first).to be_a(Package)
      end

      it "handles multiple licenses" do
        license_xml = license_xml("""
          <dependency>
            <license name='License 1'/>
            <license name='License 2'/>
          </dependency>
        """)

        fake_file = double(:license_report, read: license_xml)
        allow(Gradle).to receive(:license_report).and_return(fake_file)

        GradlePackage.should_receive(:new).with("license" => [{"name" => "License 1"}, {"name" => "License 2"}])
        Gradle.current_packages
      end

      it "handles no licenses" do
        license_xml = license_xml("""
          <dependency>
            <license name='No license found' />
          </dependency>
        """)

        fake_file = double(:license_report, read: license_xml)
        allow(Gradle).to receive(:license_report).and_return(fake_file)

        GradlePackage.should_receive(:new).with("license" => [])
        Gradle.current_packages
      end
    end

    describe '.active?' do
      let(:package) { double(:package_file) }

      before do
        Gradle.stub(package_path: package)
      end

      it 'is true with a build.gradle file' do
        package.stub(:exist? => true)
        expect(Gradle).to be_active
      end

      it 'is false without a build.gradle file' do
        package.stub(:exist? => false)
        expect(Gradle).to_not be_active
      end
    end
  end
end
