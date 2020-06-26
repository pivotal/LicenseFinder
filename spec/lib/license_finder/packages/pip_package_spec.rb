# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe PipPackage do
    subject { described_class.new('a package', '1.1.1', {}) }

    its(:package_url) { should == 'https://pypi.org/project/a+package/1.1.1/' }

    describe '.license_names_from_spec' do
      before do
        allow(License).to receive(:find_by_name).and_return(license)
      end

      context 'when license name is supported' do
        let(:spec) { { 'license' => 'some-license' } }
        let(:license) { instance_double(LicenseFinder::License, unrecognized_matcher?: false) }

        it 'should return license name from license parameter' do
          expect(described_class.license_names_from_spec(spec)).to eq(['some-license'])
        end
      end

      context 'when license name is not supported' do
        let(:spec) do
          {
            'license' => 'some-license',
            'classifiers' => [
              'some-info',
              'License :: OSI Approved :: Apache Software License'
            ]

          }
        end
        let(:license) { instance_double(LicenseFinder::License, unrecognized_matcher?: true) }

        it 'should return license name from classifier parameter' do
          expect(described_class.license_names_from_spec(spec)).to eq(['Apache Software License'])
        end
      end

      context 'when multiple licenses are provided' do
        context 'when all licenses are supported' do
          let(:spec) { { 'license' => 'some-license or some-other-license' } }
          let(:license) { instance_double(LicenseFinder::License, unrecognized_matcher?: false) }

          it 'should return license name from license parameter' do
            expect(described_class.license_names_from_spec(spec)).to eq(%w[some-license some-other-license])
          end
        end

        context 'when any of the licenses are unsupported' do
          let(:spec) do
            {
              'license' => 'some-license or some-other-license',
              'classifiers' => [
                'some-info',
                'License :: OSI Approved :: Apache Software License',
                'License :: OSI Approved :: BSD License'
              ]

            }
          end
          let(:license) { instance_double(LicenseFinder::License, unrecognized_matcher?: true) }

          it 'should return license name from classifier parameter' do
            expect(described_class.license_names_from_spec(spec)).to eq(['Apache Software License', 'BSD License'])
          end
        end
      end
    end
  end
end
