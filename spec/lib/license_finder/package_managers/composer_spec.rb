# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'
require 'json'

module LicenseFinder
  describe Composer do
    let(:root) { '/fake-composer-project' }
    let(:composer) { Composer.new project_path: Pathname.new(root) }

    it_behaves_like 'a PackageManager'

    let(:composer_shell_command_output) do
      {
        'require' => {
          'vlucas/phpdotenv' => '3.3.*'
        },
        'require-dev' => {
          'symfony/debug' => '4.2.*'
        }
      }.to_json
    end

    describe '.prepare' do
      subject { Composer.new(project_path: Pathname(root), logger: double(:logger, active: nil)) }

      include FakeFS::SpecHelpers
      before do
        FileUtils.mkdir_p(Dir.tmpdir)
        FileUtils.mkdir_p(root)
      end

      it 'should call composer install' do
        expect(SharedHelpers::Cmd).to receive(:run).with('composer install')
                                                   .and_return([composer_shell_command_output, '', cmd_success])
        subject.prepare
      end
    end
  end
end
