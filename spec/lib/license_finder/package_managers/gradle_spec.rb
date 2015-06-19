require 'spec_helper'

module LicenseFinder
  describe Gradle do
    let(:gradle) { Gradle.new }
    let(:content) { [] }

    it_behaves_like 'a PackageManager'

    describe '#current_packages' do
      before do
        allow(gradle).to receive('`').with(/gradle downloadLicenses/)

        dependencies = double(:gradle_dependency_file, dependencies: content)
        expect(GradleDependencyFinder).to receive(:new).and_return(dependencies)
      end

      it 'uses custom gradle command, if provided' do
        gradle = Gradle.new(gradle_command: "gradlefoo")
        expect(gradle).to receive('`').with(/gradlefoo downloadLicenses/)
        gradle.current_packages
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
          expect(gradle.current_packages.map(&:name)).to eq ['spring-aop', 'spring-core']
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
          expect(gradle.current_packages.first.licenses.map(&:name)).to eq ['License 1', 'License 2']
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
          expect(gradle.current_packages.first.licenses.map(&:name)).to eq ['unknown']
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
          expect(gradle.current_packages.map(&:name)).to eq ['junit', 'mockito-core']
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
            expect(gradle.current_packages.map(&:name)).to eq ['junit', 'mockito-core']
          end
        end
      end
    end
  end
end
