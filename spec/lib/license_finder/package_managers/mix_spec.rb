# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Mix do
    subject { Mix.new(project_path: Pathname('/fake/path')) }

    it_behaves_like 'a PackageManager'

    # The following output fixture looks a little odd, but it's worth explaining
    # the following inconsistencies:
    #
    # 1. The fs dep can, and does in fact have different versions in its
    # own metadata and its package metadata. We picked one for now and we're
    # not sure which one we're actually using here, so it's possible the
    # behavior isn't correct.
    #
    # 2. The gettext dep represents typical output from Mix when the package has
    # not yet been gotten and compiled.
    #
    # 3. The uuid-refknown dep represents typical output from Mix for a git
    # reference that has been fetched. Note that if the dependency is compiled
    # then the first line will contain a version number, but we felt it best
    # to refer to the revision SHA in the case of pointing to a source repo.
    #
    # 4. The uuid dep represents typical output from Mix for a git reference
    # that has not been fetched (with "mix deps.get").
    output = <<-CMDOUTPUT
* fs 0.9.1 (Hex package) (rebar)
  locked at 0.9.2 (fs) ed17036c
  ok
* gettext (Hex package) (mix)
  locked at 0.12.1 (gettext) c0624f52
  ok
* uuid-refknown (git://github.com/okeuday/uuid.git) (mix)
  locked at 15bd767
  the dependency build is outdated, please run "mix deps.compile"
* uuid (git://github.com/okeuday/uuid.git)
  the dependency is not available, run "mix deps.get"
    CMDOUTPUT

    describe '.current_packages' do
      before do
        allow(Dir).to receive(:chdir).with(Pathname('/fake/path')) { |&block| block.call }
      end

      it 'lists all the current packages' do
        allow(SharedHelpers::Cmd).to receive(:run).with('mix deps').and_return([output, '', cmd_success])
        allow(SharedHelpers::Cmd).to receive(:run).with(/mix run --no-start --no-compile -e/).and_return(['MIT', '', cmd_success])

        current_packages = subject.current_packages
        expect(current_packages.map(&:name)).to eq(['fs', 'gettext', 'uuid-refknown', 'uuid'])
        expect(current_packages.map(&:version)).to eq(['0.9.2', '0.12.1', '15bd767', 'the dependency is not available, run "mix deps.get"'])
        expect(current_packages.map(&:install_path)).to eq([Pathname('deps/fs'), Pathname('deps/gettext'), Pathname('deps/uuid-refknown'), Pathname('deps/uuid')])
      end

      it 'fails when command fails' do
        allow(SharedHelpers::Cmd).to receive(:run).with(/mix/).and_return(['Some error', '', cmd_failure]).once
        expect { subject.current_packages }.to raise_error(RuntimeError)
      end

      it 'uses custom mix command, if provided' do
        mix = Mix.new(mix_command: 'mixfoo', project_path: Pathname('/fake/path'))
        allow(SharedHelpers::Cmd).to receive(:run).with(/mixfoo/).and_return([output, '', cmd_success])

        current_packages = mix.current_packages
        expect(current_packages.map(&:name)).to eq(['fs', 'gettext', 'uuid-refknown', 'uuid'])
      end

      it 'uses custom mix_deps_dir, if provided' do
        mix = Mix.new(mix_deps_dir: 'foo', project_path: Pathname('/fake/path'))
        allow(SharedHelpers::Cmd).to receive(:run).with(/mix/).and_return([output, '', cmd_success])

        current_packages = mix.current_packages
        expect(current_packages.map(&:install_path)).to eq([Pathname('foo/fs'), Pathname('foo/gettext'), Pathname('foo/uuid-refknown'), Pathname('foo/uuid')])
      end
    end

    describe '.prepare_command' do
      it 'returns the correct prepare method' do
        expect(described_class.prepare_command).to eq('mix deps.get')
      end
    end
  end
end
