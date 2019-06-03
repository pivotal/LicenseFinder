# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Bundler do
    it_behaves_like 'a PackageManager'

    let(:definition) do
      double('definition', dependencies: [],
                           groups: %i[dev production],
                           specs_for: [
                             build_gemspec('gem1', '1.2.3'),
                             build_gemspec('gem2', '0.4.2')
                           ])
    end

    def build_gemspec(name, version, dependency = nil)
      Gem::Specification.new do |s|
        s.name = name
        s.version = version
        s.summary = 'summary'
        s.description = 'description'

        s.add_dependency dependency if dependency
      end
    end

    describe '.prepare_command' do
      it 'returns the correct prepare method' do
        expect(described_class.prepare_command).to eq('bundle install')
      end
    end

    describe '.current_packages' do
      subject do
        Bundler.new(ignored_groups: %w[dev test], project_path: Pathname.new('.'), definition: definition).current_packages
      end

      it 'should have 2 dependencies' do
        expect(subject.size).to eq(2)
      end

      context 'when initialized with a parent and child gem' do
        before do
          allow(definition).to receive(:specs_for).with([:production]).and_return([
                                                                                    build_gemspec('gem1', '1.2.3', 'gem2'),
                                                                                    build_gemspec('gem2', '0.4.2', 'gem3')
                                                                                  ])
        end

        it 'should update the child dependency with its parent data' do
          gem1 = subject.first

          expect(gem1.children).to eq(['gem2'])
        end
      end
    end
  end
end
