# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe SbtPackage do
    let(:options) { {} }
    subject do
      described_class.new(
        {
          'groupId' => 'org.scala-lang',
          'artifactId' => 'scala-library',
          'version' => '2.11.7',
          'licenses' => [{ 'name' => 'BSD 3-Clause (http://www.scala-lang.org/license.html)' }]
        },
        options
      )
    end

    its(:name) { should == 'scala-library' }
    its(:version) { should == '2.11.7' }
    its(:summary) { should == '' }
    its(:description) { should == '' }
    its(:homepage) { should == '' }
    its(:groups) { should == [] }
    its(:children) { should == [] }
    its(:install_path) { should be_nil }
    its(:package_manager) { should eq 'Sbt' }

    describe '#license_names_from_spec' do
      it 'returns the license' do
        expect(subject.license_names_from_spec).to eq ['BSD 3-Clause (http://www.scala-lang.org/license.html)']
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
          expect(subject.name).to eq('org.scala-lang:scala-library')
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
