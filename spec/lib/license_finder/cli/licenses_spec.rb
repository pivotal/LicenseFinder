# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  module CLI
    describe Licenses do
      let(:decisions) { Decisions.new }

      before do
        allow(DecisionsFactory).to receive(:decisions) { decisions }
      end

      describe 'add' do
        it 'updates the license on the requested gem' do
          silence_stdout do
            subject.add 'foo_gem', 'foo_license'
          end
          expect(subject.decisions.licenses_of('foo_gem').first.name).to eq 'foo_license'
        end

        it 'allows multiple licenses' do
          silence_stdout do
            subject.add 'foo_gem', 'one'
            subject.add 'foo_gem', 'two'
          end
          licenses = subject.decisions.licenses_of('foo_gem')
          expect(licenses.map(&:name)).to match_array %w[one two]
        end
      end

      describe 'remove' do
        it 'removes the license from the dependency' do
          silence_stdout do
            subject.add('test', 'lic')
            subject.remove('test', 'lic')
          end
          expect(subject.decisions.licenses_of('test')).to be_empty
        end

        it 'removes just one license from the dependency' do
          silence_stdout do
            subject.add('test', 'one')
            subject.add('test', 'two')
            subject.remove('test', 'one')
          end
          licenses = subject.decisions.licenses_of('test')
          expect(licenses.map(&:name)).to eq ['two']
        end

        it 'is cumulative' do
          silence_stdout do
            subject.add('test', 'lic')
            subject.remove('test', 'lic')
            subject.add('test', 'lic')
          end
          expect(subject.decisions.licenses_of('test').first.name).to eq 'lic'
        end
      end
    end
  end
end
