# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe CargoPackage do
    subject do
      described_class.new(
        'name' => 'time',
        'version' => '0.1.39',
        'id' => 'time 0.1.39 (registry+https://github.com/rust-lang/crates.io-index)',
        'license' => 'MIT/Apache-2.0',
        'license_file' => nil,
        'description' => "Utilities for working with time-related functions in Rust.\n",
        'source' => 'registry+https://github.com/rust-lang/crates.io-index',
        'dependencies' => [
          {
            'name' => 'libc',
            'source' => 'registry+https://github.com/rust-lang/crates.io-index',
            'req' => '^0.2.1',
            'kind' => nil,
            'optional' => false,
            'uses_default_features' => true,
            'features' => [],
            'target' => nil
          }
        ],
        'targets' => [
          {
            'kind' => [
              'lib'
            ],
            'crate_types' => [
              'lib'
            ],
            'name' => 'time',
            'src_path' => '/home/test/.cargo/registry/src/github.com-1ecc6299db9ec823/time-0.1.39/src/lib.rs'
          }
        ],
        'features' => {},
        'manifest_path' => '/home/test/.cargo/registry/src/github.com-1ecc6299db9ec823/time-0.1.39/Cargo.toml'
      )
    end

    its(:name) { should == 'time' }
    its(:version) { should == '0.1.39' }
    its(:summary) { should == 'Utilities for working with time-related functions in Rust.' }
    its(:homepage) { should eq '' }
    its(:groups) { should == [] }
    its(:children) { should == ['libc'] }
    its(:package_manager) { should eq 'Cargo' }

    describe '#license_names_from_spec' do
      let(:package1) { { 'license' => 'MIT' } }
      let(:package2) { { 'license' => 'MIT/Apache-2.0' } }
      let(:package3) { { 'license' => 'PSF' } }
      let(:package4) { { 'licenses' => ['MIT'] } }

      it 'finds the license for all license structures' do
        package = CargoPackage.new(package1)
        expect(package.license_names_from_spec).to eq ['MIT']

        package = CargoPackage.new(package2)
        expect(package.license_names_from_spec).to eq ['MIT', 'Apache-2.0']
      end
    end
  end
end
