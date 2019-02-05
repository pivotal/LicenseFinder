# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe BowerPackage do
    subject do
      described_class.new(
        'canonicalDir' => '/path/to/thing',
        'pkgMeta' => {
          'name' => 'dependency-library',
          'description' => 'description',
          'version' => '1.3.3.7',
          'readme' => 'some readme stuff',
          'homepage' => 'homepage'
        }
      )
    end

    its(:name) { should == 'dependency-library' }
    its(:version) { should == '1.3.3.7' }
    its(:summary) { should == 'description' }
    its(:description) { should == 'some readme stuff' }
    its(:homepage) { should == 'homepage' }
    its(:groups) { should == [] } # TODO: does `bower list` output devDependencies? If so, put them in 'dev' group?
    its(:children) { should == [] } # TODO: get dependencies from dependencies and devDependencies, like NPM
    its(:install_path) { should eq '/path/to/thing' }
    its(:package_manager) { should eq 'Bower' }

    context 'when package is NOT installed' do
      subject do
        described_class.new(
          'missing' => true,
          'endpoint' => {
            'name' => 'some_package_that_is_not_installed',
            'target' => '>=3.0'
          }
        )
      end

      it 'shows the name and version from the endpoint block' do
        expect(subject.name).to eq('some_package_that_is_not_installed')
        expect(subject.version).to eq('>=3.0')
      end

      it 'reports itself as missing' do
        expect(subject).to be_missing
      end
    end

    describe '#license_names_from_spec' do
      let(:package1) { { 'pkgMeta' => { 'license' => 'MIT' } } }
      let(:package2) { { 'pkgMeta' => { 'licenses' => [{ 'type' => 'BSD' }] } } }
      let(:package3) { { 'pkgMeta' => { 'license' => { 'type' => 'PSF' } } } }
      let(:package4) { { 'pkgMeta' => { 'licenses' => ['MIT'] } } }

      it 'finds the license for all license structures' do
        package = BowerPackage.new(package1)
        expect(package.license_names_from_spec).to eq ['MIT']

        package = BowerPackage.new(package2)
        expect(package.license_names_from_spec).to eq ['BSD']

        package = BowerPackage.new(package3)
        expect(package.license_names_from_spec).to eq ['PSF']

        package = BowerPackage.new(package4)
        expect(package.license_names_from_spec).to eq ['MIT']
      end
    end
  end
end
