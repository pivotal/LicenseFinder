require 'spec_helper'

module LicenseFinder
  describe Gradle do
    subject { Gradle.new(project_path: Pathname('/fake/path')) }
    
    let(:content) { [] }

    it_behaves_like 'a PackageManager'

    describe '#current_packages' do
      before do
        allow(subject).to receive('`').with('cd /fake/path; gradle downloadLicenses')
        dependencies = double(:subject_dependency_file, dependencies: content)
        expect(GradleDependencyFinder).to receive(:new).and_return(dependencies)
      end

      it 'uses custom subject command, if provided' do
        subject = Gradle.new(gradle_command: 'subjectfoo', project_path: '/fake/path')
        expect(subject).to receive('`').with('cd /fake/path; subjectfoo downloadLicenses')
        subject.current_packages
      end

      it 'sets the working directory to project_path, if provided' do
        subject = Gradle.new(project_path: '/Users/foo/bar')
        expect(subject).to receive('`').with('cd /Users/foo/bar; gradle downloadLicenses')
        subject.current_packages
      end

      context 'when dependencies are found' do
        let(:content) do
          [
            "<dependencies>
              <dependency name='org.springframework:spring-aop:4.0.1.RELEASE'></dependency>
              <dependency name='org.springframework:spring-core:4.0.1.RELEASE'></dependency>
            </dependencies>"
          ]
        end

        it 'lists all dependencies' do
          expect(subject.current_packages.map(&:name)).to eq ['spring-aop', 'spring-core']
        end
      end

      context 'when multiple licenses exist' do
        let(:content) do
          [
            "<dependencies>
               <dependency name=''>
                 <license name='License 1'/>
                 <license name='License 2'/>
               </dependency>
            </dependencies>"
          ]
        end

        it 'lists all dependencies' do
          expect(subject.current_packages.first.licenses.map(&:name)).to eq ['License 1', 'License 2']
        end
      end

      context 'when no licenses exist' do
        let(:content) do
          [
            "<dependencies>
              <dependency name=''></dependency>
            </dependencies>"
          ]
        end

        it 'returns unknown' do
          expect(subject.current_packages.first.licenses.map(&:name)).to eq ['unknown']
        end
      end

      context 'when multiple license files exist' do
        let(:content) do
          [
            "<dependencies>
              <dependency name='junit:junit:4.12'></dependency>
            </dependencies>",
            "<dependencies>
              <dependency name='org.mockito:mockito-core:1.9.5'></dependency>
            </dependencies>"
          ]
        end

        it 'lists all dependencies' do
          expect(subject.current_packages.map(&:name)).to eq ['junit', 'mockito-core']
        end

        context 'and there are duplicate dependencies' do
          let(:content) do
            [
              "<dependencies>
                 <dependency name='junit:junit:4.12'></dependency>
               </dependencies>",
              "<dependencies>
                 <dependency name='org.mockito:mockito-core:1.9.5'></dependency>
               </dependencies>",
              "<dependencies>
                 <dependency name='org.mockito:mockito-core:1.9.5'></dependency>
               </dependencies>"
            ]
          end

          it 'removes duplicates' do
            expect(subject.current_packages.map(&:name)).to eq ['junit', 'mockito-core']
          end
        end
      end
    end
  end
end
