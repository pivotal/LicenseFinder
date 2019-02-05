# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe MavenPackage do
    let(:options) { {} }
    subject do
      described_class.new(
        {
          'groupId' => 'org.hamcrest',
          'artifactId' => 'hamcrest-core',
          'version' => '4.11',
          'licenses' => [{ 'name' => 'MIT' }]
        },
        options
      )
    end

    its(:name) { should == 'hamcrest-core' }
    its(:version) { should == '4.11' }
    its(:summary) { should == '' }
    its(:description) { should == '' }
    its(:homepage) { should == '' }
    its(:groups) { should == [] } # no way to get groups from maven?
    its(:children) { should == [] } # no way to get children from maven?
    its(:install_path) { should be_nil }
    its(:package_manager) { should eq 'Maven' }

    describe '#license_names_from_spec' do
      it 'returns the license' do
        expect(subject.license_names_from_spec).to eq ['MIT']
      end

      context 'when there are no licenses' do
        subject { described_class.new({}) }

        it 'is empty' do
          expect(subject.license_names_from_spec).to be_empty
        end
      end

      context 'when include_groups is set to true' do
        let(:options) { { include_groups: true } }

        it 'includes the group id in the name' do
          expect(subject.name).to eq('org.hamcrest:hamcrest-core')
        end
      end

      context 'when there are multiple licenses' do
        subject do
          described_class.new(
            'licenses' => [{ 'name' => '1' }, { 'name' => '2' }]
          )
        end

        it 'returns multiple licenses' do
          expect(subject.license_names_from_spec).to eq %w[1 2]
        end
      end
    end
  end
end
