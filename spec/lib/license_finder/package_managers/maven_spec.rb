# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Maven do
    let(:options) { {} }

    subject { Maven.new(options.merge(project_path: Pathname('/fake/path'))) }

    it_behaves_like 'a PackageManager'

    def license_xml(xml)
      <<-RESP
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <licenseSummary>
          <dependencies>
            #{xml}
          </dependencies>
        </licenseSummary>
      RESP
    end

    describe '.current_packages' do
      before do
        allow(Dir).to receive(:chdir).with(Pathname('/fake/path')) { |&block| block.call }
        allow(SharedHelpers::Cmd).to receive(:run).with('mvn org.codehaus.mojo:license-maven-plugin:download-licenses').and_return(['', '', cmd_success])
      end

      def stub_license_report(deps)
        dependencies = double(:subject_dependency_file, dependencies: [license_xml(deps)])
        expect(MavenDependencyFinder).to receive(:new).and_return(dependencies)
      end

      it 'uses the maven wrapper, if present' do
        subject = Maven.new(project_path: Pathname('features/fixtures/maven-wrapper'))
        allow(SharedHelpers::Cmd).to receive(:run).with('./mvnw org.codehaus.mojo:license-maven-plugin:download-licenses').and_return(['', '', cmd_success])
        expect(Dir).to receive(:chdir).with(Pathname('features/fixtures/maven-wrapper')).and_call_original
        expect(subject.package_management_command).to eq('./mvnw').or eq('mvnw.cmd')
        subject.current_packages
      end

      it 'lists all the current packages' do
        stub_license_report("
          <dependency>
            <groupId>org.otherorg</groupId>
            <artifactId>junit</artifactId>
            <version>4.11</version>
          </dependency>
          <dependency>
            <groupId>org.hamcrest</groupId>
            <artifactId>hamcrest-core</artifactId>
            <version>1.3</version>
           </dependency>
        ")

        expect(subject.current_packages.map { |p| [p.name, p.version] }).to eq [
          ['junit', '4.11'],
          ['hamcrest-core', '1.3']
        ]
      end

      context 'when ignored_groups is used' do
        subject do
          Maven.new(options.merge(
                      project_path: Pathname('/fake/path'),
                      ignored_groups: Set.new(%w[system test provided import])
                    ))
        end

        let(:command) do
          'mvn org.codehaus.mojo:license-maven-plugin:download-licenses -Dlicense.excludedScopes=system,test,provided,import'
        end

        before do
          expect(SharedHelpers::Cmd).to receive(:run)
            .with(command)
            .and_return(['', '', cmd_success])
        end

        it 'uses skips the specified groups' do
          subject.current_packages
        end
      end

      it 'handles multiple licenses' do
        stub_license_report("
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

        expect(subject.current_packages.first.licenses.map(&:name)).to eq ['License 1', 'License 2']
      end

      context 'when maven group ids option is enabled' do
        let(:options) { { maven_include_groups: true } }

        it 'lists all the current packages' do
          stub_license_report("
            <dependency>
              <groupId>junit</groupId>
              <artifactId>junit</artifactId>
              <version>4.11</version>
            </dependency>
            <dependency>
              <groupId>org.hamcrest</groupId>
              <artifactId>hamcrest-core</artifactId>
              <version>1.3</version>
            </dependency>
          ")

          expect(subject.current_packages.map { |p| [p.name, p.version] }).to eq [
            ['junit:junit', '4.11'],
            ['org.hamcrest:hamcrest-core', '1.3']
          ]
        end
      end

      it 'handles no licenses' do
        stub_license_report("
          <dependency>
          </dependency>
        ")

        expect(subject.current_packages.first.licenses.map(&:name)).to eq ['unknown']
      end
    end
  end
end
