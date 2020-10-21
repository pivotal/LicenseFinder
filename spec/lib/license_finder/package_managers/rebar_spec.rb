# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Rebar do
    subject { Rebar.new(project_path: Pathname('/fake/path')) }

    it_behaves_like 'a PackageManager'

    tree_output = <<-TREEOUTPUT
===> bababooie
└─ eetcd─0.3.2 (project app)
   └─ hackney─1.6.0 (hex package)
      └─ ssl_verify_fun─1.1.0 (hex package)
    TREEOUTPUT

    pkgs_output = <<-PKGSOUTPUT
hexpm:
    Name: hackney
    Description: simple HTTP client
    Licenses: Apache 2.0
    Links:
        Github: https://github.com/benoitc/hackney
    Versions: 1.16.0
    PKGSOUTPUT

    describe '.current_packages' do
      before do
        allow(Dir).to receive(:chdir).with(Pathname('/fake/path')) { |&block| block.call }
      end

      it 'lists all the current packages' do
        allow(SharedHelpers::Cmd).to receive(:run).with('rebar3 tree').and_return([tree_output, '', cmd_success])
        allow(SharedHelpers::Cmd).to receive(:run).with(/rebar3 pkgs .*/).and_return([pkgs_output, '', cmd_success])

        current_packages = subject.current_packages
        expect(current_packages.map(&:name)).to eq(%w[hackney ssl_verify_fun])
        expect(current_packages.map(&:version)).to eq(%w[1.6.0 1.1.0])
        expect(current_packages.map(&:license_names_from_spec)).to eq([['Apache 2.0'], ['Apache 2.0']])
        expect(current_packages.map(&:homepage)).to eq(%w[https://github.com/benoitc/hackney https://github.com/benoitc/hackney])
        expect(current_packages.map(&:install_path)).to eq([Pathname('/fake/path/_build/default/lib/hackney'), Pathname('/fake/path/_build/default/lib/ssl_verify_fun')])
      end

      it 'fails when tree command fails' do
        allow(SharedHelpers::Cmd).to receive(:run).with('rebar3 tree').and_return(['Some error', '', cmd_failure]).once
        expect { subject.current_packages }.to raise_error(RuntimeError)
      end

      context 'when pkgs command fails' do
        it 'returns empty license and homepage information' do
          allow(SharedHelpers::Cmd).to receive(:run).with('rebar3 tree').and_return([tree_output, '', cmd_success])
          allow(SharedHelpers::Cmd).to receive(:run).with(/rebar3 pkgs .*/).and_return(['Some error', '', cmd_failure])

          current_packages = subject.current_packages
          expect(current_packages.map(&:name)).to eq(%w[hackney ssl_verify_fun])
          expect(current_packages.map(&:version)).to eq(%w[1.6.0 1.1.0])
          expect(current_packages.map(&:license_names_from_spec)).to eq([[], []])
          expect(current_packages.map(&:homepage)).to eq(['', ''])
          expect(current_packages.map(&:install_path)).to eq([Pathname('/fake/path/_build/default/lib/hackney'), Pathname('/fake/path/_build/default/lib/ssl_verify_fun')])
        end
      end

      it 'uses custom rebar command, if provided' do
        rebar = Rebar.new(rebar_command: 'rebarfoo', project_path: Pathname('/fake/path'))
        allow(SharedHelpers::Cmd).to receive(:run).with('rebarfoo tree').and_return([tree_output, '', cmd_success])
        allow(SharedHelpers::Cmd).to receive(:run).with(/rebarfoo pkgs .*/).and_return([pkgs_output, '', cmd_success])

        current_packages = rebar.current_packages
        expect(current_packages.map(&:name)).to eq(%w[hackney ssl_verify_fun])
        expect(current_packages.map(&:version)).to eq(%w[1.6.0 1.1.0])
        expect(current_packages.map(&:license_names_from_spec)).to eq([['Apache 2.0'], ['Apache 2.0']])
        expect(current_packages.map(&:homepage)).to eq(%w[https://github.com/benoitc/hackney https://github.com/benoitc/hackney])
        expect(current_packages.map(&:install_path)).to eq([Pathname('/fake/path/_build/default/lib/hackney'), Pathname('/fake/path/_build/default/lib/ssl_verify_fun')])
      end

      it 'uses custom rebar_deps_dir, if provided' do
        rebar = Rebar.new(rebar_deps_dir: 'foo', project_path: Pathname('/fake/path'))
        allow(SharedHelpers::Cmd).to receive(:run).with('rebar3 tree').and_return([tree_output, '', cmd_success])
        allow(SharedHelpers::Cmd).to receive(:run).with(/rebar3 pkgs .*/).and_return([pkgs_output, '', cmd_success])

        current_packages = rebar.current_packages
        expect(current_packages.map(&:install_path)).to eq([Pathname('foo/hackney'), Pathname('foo/ssl_verify_fun')])
      end
    end
  end
end
