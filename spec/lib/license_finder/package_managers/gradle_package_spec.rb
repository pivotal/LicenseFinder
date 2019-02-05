# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe GradlePackage do
    subject do
      described_class.new(
        'name' => 'ch.qos.logback:logback-classic:1.1.1',
        'license' => [{ 'name' => 'MIT' }]
      )
    end

    its(:name) { should == 'logback-classic' }
    its(:version) { should == '1.1.1' }
    its(:authors) { should == '' }
    its(:summary) { should == '' }
    its(:description) { should == '' }
    its(:homepage) { should == '' }
    its(:groups) { should == [] } # no way to get groups from gradle?
    its(:children) { should == [] } # no way to get children from gradle?
    its(:install_path) { should be_nil }
    its(:package_manager) { should eq 'Gradle' }

    describe 'when file name has a funny format, possibly because it is a jar saved in the project' do
      it 'uses a reasonable name and default version' do
        subject = described_class.new('name' => 'data.json-0.2.3.jar')
        expect(subject.name).to eq 'data.json-0.2.3.jar'
        expect(subject.version).to eq 'unknown'
      end
    end

    describe '#license_names_from_spec' do
      it 'returns the license' do
        expect(subject.license_names_from_spec).to eq ['MIT']
      end

      context 'when there are no licenses' do
        subject { described_class.new('name' => 'a:b:c') }

        it 'is empty' do
          expect(subject.license_names_from_spec).to be_empty
        end
      end

      context 'when include_groups is set to true' do
        subject { described_class.new({ 'name' => 'a:b:c' }, include_groups: true) }

        it 'includes the group id in the name' do
          expect(subject.name).to eq('a:b')
        end
      end

      context 'when there are no real licenses' do
        subject do
          described_class.new(
            'name' => 'a:b:c',
            'license' => [{ 'name' => 'No license found' }]
          )
        end

        it 'is empty' do
          expect(subject.license_names_from_spec).to be_empty
        end
      end

      context 'when there are multiple licenses' do
        subject do
          described_class.new(
            'name' => 'a:b:c',
            'license' => [{ 'name' => '1' }, { 'name' => '2' }]
          )
        end

        it 'returns multiple licenses' do
          expect(subject.license_names_from_spec).to eq %w[1 2]
        end
      end
    end
  end
end
