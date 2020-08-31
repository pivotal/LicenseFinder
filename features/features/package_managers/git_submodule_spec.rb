# frozen_string_literal: true

require_relative '../../support/feature_helper'
require_relative '../../../lib/license_finder/platform'

describe 'Git Submodule Dependencies' do
  # As a developer
  # I want to be able to use git submodules

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::GitSubmoduleProject.create
    developer.run_license_finder
    expect(developer).to be_seeing_line 'subs/licensefinder, v6.8.1-8-ga6d56c7a, MIT'
  end
end
