require_relative '../../support/feature_helper'

describe "Composer Dependencies" do
  # As a PHP developer
  # I want to be able to manage composer dependencies

  let(:php_developer) { LicenseFinder::TestingDSL::User.new }

  specify "are shown in reports" do
    LicenseFinder::TestingDSL::ComposerProject.create
    php_developer.run_license_finder
    expect(php_developer).to be_seeing_line "vlucas/phpdotenv, v2.3.0, BSD-3-Clause-Attribution"
  end
end