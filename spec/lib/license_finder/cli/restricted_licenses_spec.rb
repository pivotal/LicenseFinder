# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  module CLI
    describe RestrictedLicenses do
      let(:decisions) { Decisions.new }

      before do
        allow(DecisionsFactory).to receive(:decisions) { decisions }
      end

      describe 'list' do
        it 'shows the restricted licenses' do
          decisions.restrict('MIT')

          expect(capture_stdout { subject.list }).to match /MIT/
        end
      end

      describe 'add' do
        it 'adds the specified license to the restricted licenses' do
          silence_stdout do
            subject.add('test')
          end
          expect(subject.decisions.restricted).to eq [License.find_by_name('test')].to_set
        end

        it 'adds multiple licenses to the restricted licenses' do
          silence_stdout do
            subject.add('test', 'rest')
          end
          expect(subject.decisions.restricted).to eq [
            License.find_by_name('test'),
            License.find_by_name('rest')
          ].to_set
        end
      end

      describe 'remove' do
        it 'removes the specified license from the restricted licenses' do
          silence_stdout do
            subject.add('test')
            subject.remove('test')
          end
          expect(subject.decisions.restricted).to be_empty
        end

        it 'removes multiple licenses from the restricted licenses' do
          silence_stdout do
            subject.add('test', 'rest')
            subject.remove('test', 'rest')
          end
          expect(subject.decisions.restricted).to be_empty
        end
      end
    end
  end
end
