# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  module CLI
    describe IgnoredDependencies do
      let(:decisions) { Decisions.new }

      before do
        allow(DecisionsFactory).to receive(:decisions) { decisions }
      end

      describe 'list' do
        context 'when there is at least one ignored dependency' do
          it 'shows the ignored dependencies' do
            decisions.ignore('bundler')
            expect(capture_stdout { subject.list }).to match /bundler/
          end
        end

        context 'when there are no ignored dependencies' do
          it "prints '(none)'" do
            expect(capture_stdout { subject.list }).to match /\(none\)/
          end
        end
      end

      describe 'add' do
        it 'adds the specified group to the ignored groups list' do
          silence_stdout do
            subject.add('test')
          end
          expect(subject.decisions.ignored).to eq ['test'].to_set
        end
      end

      describe 'remove' do
        it 'removes the specified group from the ignored groups list' do
          silence_stdout do
            subject.add('test')
            subject.remove('test')
          end
          expect(subject.decisions.ignored).to be_empty
        end
      end
    end
  end
end
