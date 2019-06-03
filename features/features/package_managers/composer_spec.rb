# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Composer Dependencies' do
  let(:php_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::ComposerProject.create
    php_developer.run_license_finder
    expect(php_developer).to be_seeing_line 'vlucas/phpdotenv, v3.3.3, "New BSD"'
    expect(php_developer).to be_seeing_line 'symfony/debug, v4.2.8, MIT'
  end
end
