# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Pipenv Dependencies' do
  # As a Python developer
  # I want to be able to manage Pipenv dependencies

  let(:python_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::PipenvProject.create
    python_developer.run_license_finder
    expect(python_developer).to be_seeing_line 'six, 1.13.0, "MIT"'
  end
end
