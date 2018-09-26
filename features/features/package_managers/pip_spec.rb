# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Pip Dependencies' do
  # As a Python developer
  # I want to be able to manage Pip dependencies

  let(:python_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::PipProject.create
    python_developer.run_license_finder
    expect(python_developer).to be_seeing_line 'rsa, 3.1.4, "ASL 2"'
  end
end
