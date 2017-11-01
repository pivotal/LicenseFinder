require 'spec_helper'

describe LicenseFinder::Logger do
  describe LicenseFinder::Logger::Verbose do
    describe '#log' do
      it 'should output normal color to screen when no color is provided' do
        expect(subject).to receive(:printf).with("%s: %s\n", 'Log', 'Test Output')
        subject.log 'Log', 'Test Output'
      end

      it 'should output red string to screen when red is provided' do
        expect(subject).to receive(:printf).with("%s: %s\n", 'Log', "\e[31mTest Output\e[0m")
        subject.log 'Log', 'Test Output', color: :red
      end

      it 'should output green string to screen when green is provided' do
        expect(subject).to receive(:printf).with("%s: %s\n", 'Log', "\e[32mTest Output\e[0m")
        subject.log 'Log', 'Test Output', color: :green
      end
    end
  end
end
