# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Configuration do
    describe '.with_optional_saved_config' do
      it 'should init and use saved config' do
        subject = described_class.with_optional_saved_config(project_path: fixture_path('.'))
        expect(subject.gradle_command).to eq('gradlew')
      end

      it 'prepends the project_path to the config file path' do
        subject = described_class.with_optional_saved_config(project_path: 'other_directory')
        expect(subject.send(:saved_config)).to eq({})
      end
    end

    describe '#valid_project_path?' do
      it 'returns false when the path does not exist' do
        subject = described_class.with_optional_saved_config(project_path: '/path/that/does/not/exist')
        expect(subject.valid_project_path?).to be(false)
      end

      it 'returns true when the path exists' do
        subject = described_class.with_optional_saved_config(project_path: '/')
        expect(subject.valid_project_path?).to be(true)
      end

      it 'returns true if the path is not provided' do
        subject = described_class.with_optional_saved_config({})
        expect(subject.valid_project_path?).to be(true)
      end
    end

    describe 'gradle_command' do
      it 'prefers primary value' do
        subject = described_class.new(
          { gradle_command: 'primary' },
          'gradle_command' => 'secondary'
        )
        expect(subject.gradle_command).to eq 'primary'
      end

      it 'accepts saved value' do
        subject = described_class.new(
          { gradle_command: nil },
          'gradle_command' => 'secondary'
        )
        expect(subject.gradle_command).to eq 'secondary'
      end
    end

    describe '#decisions_file' do
      it 'has default' do
        subject = described_class.new(
          { decisions_file: nil },
          'decisions_file' => nil
        )
        expect(subject.decisions_file_path.to_s).to end_with 'doc/dependency_decisions.yml'
      end

      it 'prefers primary value' do
        subject = described_class.new(
          { decisions_file: 'primary' },
          'decisions_file' => 'secondary'
        )
        expect(subject.decisions_file_path.to_s).to end_with 'primary'
      end

      it 'accepts saved value' do
        subject = described_class.new(
          { decisions_file: nil },
          'decisions_file' => 'secondary'
        )
        expect(subject.decisions_file_path.to_s).to end_with 'secondary'
      end

      it 'prepends project path to default path if project_path option is set' do
        subject = described_class.new({ project_path: 'magic_path' }, {})
        expect(subject.decisions_file_path.to_s).to end_with 'magic_path/doc/dependency_decisions.yml'
      end

      it 'prefers decisions_file over project_path' do
        subject = described_class.new(
          { project_path: 'magic_path',
            decisions_file: 'better_path' },
          'decisions_file' => nil
        )
        expect(subject.decisions_file_path.to_s).to end_with 'better_path'
      end
    end

    describe 'log_directory' do
      it 'prefers primary value' do
        subject = described_class.new(
          { log_directory: 'primary' },
          'log_directory' => 'secondary'
        )
        expect(subject.log_directory.to_s).to end_with 'primary'
      end

      it 'accepts saved value' do
        subject = described_class.new(
          { log_directory: nil },
          'log_directory' => 'secondary'
        )
        expect(subject.log_directory.to_s).to end_with 'secondary'
      end

      it 'has default' do
        subject = described_class.new(
          { log_directory: nil },
          'log_directory' => nil
        )
        expect(subject.log_directory.to_s).to end_with 'lf_logs'
      end

      it 'prepends project path to default path if project_path option is set and not recursive' do
        subject = described_class.new(
          { project_path: 'magic_path',
            recursive: false,
            aggregate_paths: false }, {}
        )
        expect(subject.log_directory.to_s).to end_with 'magic_path/lf_logs'
      end

      it 'prepends project path to default path if project_path option is not set and not recursive' do
        subject = described_class.new(
          { project_path: nil,
            recursive: true,
            aggregate_paths: true }, {}
        )
        expect(subject.log_directory.to_s).to_not end_with 'magic_path/lf_logs'
        expect(subject.log_directory.to_s).to end_with 'lf_logs'
      end

      it 'prepends project path to default path if project_path option is set and not recursive' do
        subject = described_class.new(
          { project_path: 'magic_path',
            recursive: true,
            aggregate_paths: true }, {}
        )
        expect(subject.log_directory.to_s).to end_with 'magic_path/lf_logs'
      end

      it 'prepends project path to provided value' do
        subject = described_class.new({ log_directory: 'primary',
                                        project_path: 'magic_path' },
                                      'log_directory' => 'secondary')
        expect(subject.log_directory.to_s).to end_with 'magic_path/primary'
      end
    end

    describe 'rebar_deps_dir' do
      it 'has default' do
        subject = described_class.new(
          { rebar_deps_dir: nil },
          'rebar_deps_dir' => nil
        )
        expect(subject.rebar_deps_dir.to_s).to end_with 'deps'
      end

      it 'prepends project path to default path if project_path option is set' do
        subject = described_class.new({ project_path: 'magic_path' }, {})
        expect(subject.rebar_deps_dir.to_s).to end_with 'magic_path/deps'
      end

      it 'prepends project path to provided value' do
        subject = described_class.new(
          { rebar_deps_dir: 'primary',
            project_path: 'magic_path' },
          'rebar_deps_dir' => 'secondary'
        )
        expect(subject.rebar_deps_dir.to_s).to end_with 'magic_path/primary'
      end
    end

    describe 'mix_deps_dir' do
      it 'has default' do
        subject = described_class.new(
          { mix_deps_dir: nil },
          'mix_deps_dir' => nil
        )
        expect(subject.mix_deps_dir.to_s).to end_with 'deps'
      end

      it 'prepends project path to default path if project_path option is set' do
        subject = described_class.new({ project_path: 'magic_path' }, {})
        expect(subject.mix_deps_dir.to_s).to end_with 'magic_path/deps'
      end

      it 'prepends the saved config value if set' do
        subject = described_class.new({}, 'mix_command' => 'savedmix')
        expect(subject.mix_command.to_s).to eq 'savedmix'
      end

      it 'prepends project path to provided value' do
        subject = described_class.new(
          { mix_deps_dir: 'primary',
            project_path: 'magic_path' },
          'mix_deps_dir' => 'secondary'
        )
        expect(subject.mix_deps_dir.to_s).to end_with 'magic_path/primary'
      end
    end

    describe 'mix_command' do
      it 'has default' do
        subject = described_class.new(
          { mix_command: nil },
          'mix_command' => nil
        )
        expect(subject.mix_command.to_s).to eq 'mix'
      end

      it 'defaults the mix_command to mix' do
        subject = described_class.new({}, {})
        expect(subject.mix_command.to_s).to eq 'mix'
      end

      it 'defaults to the saved config if set' do
        subject = described_class.new({}, 'mix_command' => 'savedmix')
        expect(subject.mix_command.to_s).to eq 'savedmix'
      end

      it 'overrides the mix command if specified' do
        subject = described_class.new(
          { mix_command: 'newmix' },
          'mix_command' => 'mix'
        )
        expect(subject.mix_command.to_s).to eq 'newmix'
      end
    end

    describe '#prepare' do
      it 'should return true as long as --prepare or --prepare_no_fail' do
        subject = described_class.new(
          { prepare: true },
          {}
        )
        expect(subject.prepare).to be_truthy
        subject = described_class.new(
          { prepare_no_fail: true },
          {}
        )
        expect(subject.prepare).to be_truthy
      end

      it 'should return false if no --prepare AND no --prepare_no_fail' do
        subject = described_class.new(
          {},
          {}
        )
        expect(subject.prepare).to be_falsey
      end
    end

    describe '#prepare_no_fail' do
      it 'returns true if --prepare_no_fail' do
        subject = described_class.new(
          { prepare_no_fail: true },
          {}
        )
        expect(subject.prepare).to be_truthy
      end

      it 'returns false if --prepare_no_fail is not set' do
        subject = described_class.new(
          {},
          {}
        )
        expect(subject.prepare).to be_falsey
      end
    end

    describe '#merge' do
      it 'should return a new config with an altered project path' do
        subject = described_class.with_optional_saved_config(project_path: '/path/to/project')
        duped_subject = subject.merge(project_path: '/path/to/other/project')

        expect(duped_subject.project_path.to_s).to eq '/path/to/other/project'
        expect(subject.project_path.to_s).to eq '/path/to/project'
        expect(subject.project_path).to_not eq duped_subject.project_path
      end
    end

    describe '#save_file' do
      context 'when there is no save file present' do
        it 'returns the save file path' do
          subject = described_class.with_optional_saved_config(project_path: '/path/to/project', save: '/path/to/save_file')

          expect(subject.save_file).to eq '/path/to/save_file'
        end
      end

      context 'when there is a save file present' do
        it 'returns the save file path when no primary ' do
          allow(Pathname).to receive(:expand_path).and_return Pathname('/path/to/project').expand_path
          allow(YAML).to receive(:safe_load).and_return(project_path: '/path/to/project', save: '/path/to/save_file')

          subject = described_class.with_optional_saved_config(project_path: '/path/to/project', save: '/path/to/save_file')

          expect(subject.save_file).to eq '/path/to/save_file'
        end
      end
    end
  end
end
