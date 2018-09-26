# frozen_string_literal: true

require 'spec_helper'
module LicenseFinder
  module CLI
    describe ProjectName do
      let(:decisions) { Decisions.new }

      before do
        allow(DecisionsFactory).to receive(:decisions) { decisions }
      end

      describe 'show' do
        it 'shows the configured project name' do
          decisions.name_project('test')
          expect(capture_stdout { subject.show }).to match /test/
        end
      end

      describe 'add' do
        it 'sets the project name' do
          silence_stdout do
            subject.add('test')
          end
          expect(subject.decisions.project_name).to eq 'test'
        end
      end

      describe 'remove' do
        it 'removes the project name' do
          silence_stdout do
            subject.add('test')
            subject.remove
          end
          expect(subject.decisions.project_name).to be_nil
        end
      end
    end
  end
end
