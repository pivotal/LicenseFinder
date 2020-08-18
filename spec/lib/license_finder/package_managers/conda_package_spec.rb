# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe CondaPackage do
    subject do
      make_package
    end

    def make_package(more_info = {})
      described_class.new(
        {
          'name' => 'ruamel_yaml',
          'version' => '0.15.87',
          'url' => 'https://repo.anaconda.com/pkgs/main/linux-64/ruamel_yaml-0.15.87-py38h7b6447c_1.conda',
          'license' => 'MIT',
          'license_family' => 'MIT',
          'depends' => [
            'libgcc-ng >=7.3.0',
            'python >=3.8,<3.9.0a0',
            'yaml >=0.2.5,<0.3.0a0'
          ]
        }.merge(more_info)
      )
    end

    its(:name) { should == 'ruamel_yaml' }
    its(:version) { should == '0.15.87' }
    its(:authors) { should == '' }
    its(:summary) { should == '' }
    its(:description) { should == '' }
    its(:homepage) { should == '' }
    its(:children) { should == ['libgcc-ng', 'python', 'yaml'] }
    its(:install_path) { should be nil}
    its(:package_manager) { should eq 'Conda' }

    describe '#license_names_from_spec' do
      context 'with a simple MIT license' do
        its('licenses.first.pretty_name') { should == 'MIT' }
      end

      describe 'with nothing from conda search --info' do
        it 'is empty' do
          subject = make_package('license' => [], 'license_family' => nil)

          expect(subject.license_names_from_spec).to be_empty
        end
      end
    end
  end
end
