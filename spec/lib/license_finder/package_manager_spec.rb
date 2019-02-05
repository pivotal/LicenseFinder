# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe PackageManager do
    let(:logger) { double(:logger, debug: true, info: true) }

    describe '#current_packages_with_relations' do
      it "sets packages' parents" do
        grandparent = Package.new('grandparent', nil, children: ['parent'])
        parent      = Package.new('parent',      nil, children: ['child'])
        child       = Package.new('child')

        pm = described_class.new
        allow(pm).to receive(:current_packages) { [grandparent, parent, child] }

        expect(pm.current_packages_with_relations.map(&:parents)).to eq([
                                                                          [].to_set,
                                                                          ['grandparent'].to_set,
                                                                          ['parent'].to_set
                                                                        ])
      end

      context 'when --prepare-no-fail flag is set' do
        let(:subject) { described_class.new(logger: logger, prepare_no_fail: true) }

        it 'does not throw an error when current packages fails' do
          allow(subject).to receive(:current_package).and_raise
          expect { subject.current_packages_with_relations }.to_not raise_error
        end
      end
    end

    describe '.package_management_command' do
      it 'defaults to nil' do
        expect(LicenseFinder::PackageManager.package_management_command).to be_nil
      end
    end

    describe '.installed?' do
      context 'package_management_command is nil' do
        before do
          allow(LicenseFinder::PackageManager).to receive(:package_management_command).and_return(nil)
        end

        it 'returns true' do
          expect(LicenseFinder::PackageManager.installed?).to be_truthy
        end
      end

      context 'package_management_command exists' do
        before do
          allow(LicenseFinder::PackageManager).to receive(:package_management_command).and_return('foobar')
          allow(LicenseFinder::PackageManager).to receive(:command_exists?).with('foobar').and_return(true)
        end

        it 'returns true' do
          expect(LicenseFinder::PackageManager.installed?).to be_truthy
        end
      end

      context 'package_management_command does not exist' do
        before do
          allow(LicenseFinder::PackageManager).to receive(:package_management_command).and_return('foobar')
          allow(LicenseFinder::PackageManager).to receive(:command_exists?).with('foobar').and_return(false)
        end

        it 'returns false' do
          expect(LicenseFinder::PackageManager.installed?(logger)).to be_falsey
        end
      end
    end

    describe '#prepare' do
      context 'when there is a prepare_command' do
        let(:prepare_error) { /Prepare command .* failed/ }
        let(:project_path) { '/path/to/project' }
        let(:log_directory) { '/path/to/project/logs/project' }
        let(:log_file_path) { File.join(log_directory, 'prepare_errors.log') }
        let(:quiet_logger) { double(:logger) }
        let(:subject) { described_class.new logger: quiet_logger, project_path: project_path, log_directory: log_directory }

        before do
          FakeFS.activate!
          FileUtils.mkdir_p project_path
          allow(described_class).to receive(:prepare_command).and_return('sh commands')
          allow(described_class).to receive(:prepare_command).and_return('sh commands')
        end

        after do
          FakeFS.clear!
          FakeFS.deactivate!
        end

        it 'succeeds when prepare command runs successfully' do
          expect(SharedHelpers::Cmd).to receive(:run).with('sh commands').and_return(['output', nil, cmd_success])

          expect { subject.prepare }.to_not raise_error
        end

        it 'logs warning and exception when prepare command runs into failure' do
          expect(SharedHelpers::Cmd).to receive(:run).with('sh commands').and_return(['output', 'failure error msg', cmd_failure])
          expect(quiet_logger).to receive(:info).with('sh commands', 'did not succeed.', color: :red)
          expect(quiet_logger).to receive(:info).with('sh commands', 'failure error msg', color: :red)
          expect { subject.prepare }.to raise_error(prepare_error)
        end

        describe 'logging prepare errors into log file' do
          let(:subject) { described_class.new logger: logger, project_path: project_path, log_directory: log_directory }
          let(:error_msg) { "Prepare command \"sh commands\" failed with:\nfailure error msg\n\n" }

          before do
            expect(SharedHelpers::Cmd).to receive(:run).with('sh commands').and_return(['output', 'failure error msg', cmd_failure])
          end

          it 'logs package manager failure messages in log file for package manager' do
            expect { subject.prepare }.to raise_error(prepare_error)
            expect(File.read(log_file_path)).to eq error_msg
          end

          it 'discards previous logs and starts logging new logs' do
            FileUtils.mkdir_p log_directory
            File.open(log_file_path, 'w') { |f| f.write('previous logs') }
            expect { subject.prepare }.to raise_error(prepare_error)
            expect(File.read(log_file_path)).to eq error_msg
          end

          it 'uses default package_management_command as the file name' do
            expect { subject.prepare }.to raise_error(prepare_error)
            expect(File.exist?(log_file_path))
          end

          it 'uses defined package_management_command as the file name' do
            allow(LicenseFinder::PackageManager).to receive(:package_management_command).and_return('foobar')
            expect { subject.prepare }.to raise_error(prepare_error)
            expect(File.exist?(File.join(log_directory, 'prepare_foobar.log'))).to be_truthy
          end

          context 'when prepare command has whitespaces and slashes in it' do
            before do
              allow(described_class).to receive(:package_management_command)
                                          .and_return('mono /usr/local/bin/nuget.exe')
            end

            let(:log_file_path) { File.join(log_directory, 'prepare_mono_usrlocalbinnuget.exe.log') }

            it 'creates log files with whitespaces replaced by underscores and slashes removed' do
              expect { subject.prepare }.to raise_error(prepare_error)
              expect(File.read(log_file_path)).to eq error_msg
            end
          end
        end

        context 'with prepare_no_fail' do
          let(:subject) { described_class.new logger: logger, prepare_no_fail: true, project_path: project_path, log_directory: log_directory }

          it 'should not throw an error when prepare_command fails' do
            expect(SharedHelpers::Cmd).to receive(:run).with('sh commands')
                                                       .and_return(['output', 'failure error msg', cmd_failure])
            expect { subject.prepare }.to_not raise_error
          end
        end
      end

      context 'when there is no prepare_command' do
        it 'issues a warning' do
          logger = double(:logger)
          expect(logger).to receive(:debug).with(described_class, 'no prepare step provided', color: :red)
          expect(SharedHelpers::Cmd).to_not receive(:run).with('sh commands')

          subject = described_class.new(logger: logger)
          subject.prepare
        end
      end
    end
  end
end
