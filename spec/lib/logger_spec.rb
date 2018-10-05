# frozen_string_literal: true

require 'spec_helper'

describe LicenseFinder::Logger do
  let(:system_logger) { double(:logger, :formatter= => true, :level= => true) }

  before do
    allow(Logger).to receive(:new).and_return(system_logger)
  end

  it 'has default mode of :info' do
    expect(subject.mode).to eq(:info)
  end

  it 'should forward all calls to the system logger' do
    # debug calls should match debug system logger calls
    # info calls should match info system logger calls
    # etc
    prefix = 'pre '
    string = 'test'
    logged_string = "#{prefix}: #{string}"
    subject = described_class.new(mode: :info)

    [LicenseFinder::Logger::MODE_INFO, LicenseFinder::Logger::MODE_DEBUG].each do |level|
      expect(system_logger).to receive(level).with(logged_string)
      subject.send(level, prefix, string)
    end
  end

  context 'when the log level is set to --debug' do
    it 'should log all information' do
      # set system logger level to x
      expect(system_logger).to receive(:level=).with Logger::DEBUG
      described_class.new(:debug)
    end
  end

  context 'when the log level is set to --quiet' do
    it 'should not log any information' do
      subject = described_class.new(:quiet)

      [LicenseFinder::Logger::MODE_INFO, LicenseFinder::Logger::MODE_DEBUG].each do |level|
        expect(system_logger).to_not receive(level)
        subject.send(level, 'prefix', 'string')
      end
    end
  end

  context 'when the log level is set to --default' do
    it 'should log only standard information' do
      expect(system_logger).to receive(:level=).with Logger::INFO
      described_class.new(:info)
    end
  end
end
