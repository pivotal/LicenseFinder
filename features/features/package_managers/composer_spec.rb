# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Composer Dependencies' do
  let(:php_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    composer_project = LicenseFinder::TestingDSL::ComposerProject.create
    php_developer.run_license_finder(nil, '--columns=name version licenses install_path')
    expect(php_developer).to be_seeing_line "vlucas/phpdotenv, v3.3.3, \"New BSD\", #{composer_project.project_dir}/vendor/vlucas/phpdotenv"
    expect(php_developer).to be_seeing_line "symfony/debug, v4.2.8, MIT, #{composer_project.project_dir}/vendor/symfony/debug"
  end
end
