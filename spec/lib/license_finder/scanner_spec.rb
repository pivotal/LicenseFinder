# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Scanner do
    let(:logger) { double(:logger, debug: true, info: true) }
    let(:subject) { described_class.new(logger: logger, project_path: Pathname.new('')) }

    describe '#active_packages' do
      before do
        bundler = double(:bundler, active?: true, class: Bundler)
        allow(Bundler).to receive(:new).and_return bundler
        allow(bundler).to receive(:current_packages_with_relations)
        allow(Bundler).to receive(:package_management_command).and_return 'command'
      end

      context 'when package manager is installed' do
        it 'should log all active packages' do
          allow(Bundler).to receive(:command_exists?).and_return true
          expect(logger).to receive(:debug).with(Bundler, 'is installed', color: :green)
          expect(subject.active_packages).to_not be_nil
        end
      end

      context 'when package manager is NOT installed' do
        it 'should log all active packages' do
          allow(Bundler).to receive(:command_exists?).and_return false
          expect(logger).to receive(:info).with(Bundler, 'is active', color: :green)
          expect(logger).to receive(:info).with(Bundler, 'is not installed', color: :red)
          expect(subject.active_packages).to_not be_nil
        end
      end
    end

    describe '#active_package_managers' do
      it 'should return active package managers' do
        bundler = double(:bundler, active?: true)
        allow(Bundler).to receive(:new).and_return bundler
        expect(subject.active_package_managers).to include bundler
      end

      it 'should log active states of package managers' do
        bundler = double(:bundler, active?: true)
        allow(Bundler).to receive(:new).and_return bundler
        expect(logger).to receive(:info).with(Bundler, 'is active', color: :green)

        subject.active_package_managers
      end

      it 'should log inactive states of package managers' do
        bundler = double(:bundler, active?: false)
        allow(Bundler).to receive(:new).and_return bundler
        expect(logger).to receive(:debug).with(Bundler, 'is not active', color: :red)

        subject.active_package_managers
      end

      it 'should exclude GoVendor when Gvt is active' do
        gvt = Gvt.new
        allow(Gvt).to receive(:new).and_return gvt
        allow(gvt).to receive(:active?).and_return true
        govendor = Go15VendorExperiment.new
        allow(Go15VendorExperiment).to receive(:new).and_return govendor
        allow(govendor).to receive(:active?).and_return true
        expect(subject.active_package_managers).to include gvt
        expect(subject.active_package_managers).not_to include govendor
      end

      context 'when there are no active package managers' do
        it 'should show an appropriate error message' do
          described_class::PACKAGE_MANAGERS.each do |pm|
            d = double(pm.name, active?: false, class: pm)
            allow(pm).to receive(:new).and_return d
          end
          expect(logger).to receive(:info).with('License Finder', 'No active and installed package managers found for project.', color: :red)
          subject.active_package_managers
        end
      end
    end
  end
end
