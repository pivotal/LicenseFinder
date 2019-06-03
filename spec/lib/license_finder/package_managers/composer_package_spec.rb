# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe ComposerPackage do
    subject do
      described_class.new('symfony/debug', 'v3.0.7', 'license' => [{ 'name' => 'MIT' }])
    end

    its(:name) { should == 'symfony/debug' }
    its(:version) { should == 'v3.0.7' }
    its(:summary) { should eq '' }
    its(:description) { should == '' }
    its(:homepage) { should == '' }
    its(:package_manager) { should eq 'Composer' }

    describe '#license_names_from_spec' do
      it 'finds the license for both license structures' do
        package = ComposerPackage.new('test', 'v1.2.3', spec_licenses: ['MIT'])
        expect(package.license_names_from_spec).to eq ['MIT']
      end
    end
  end
end
