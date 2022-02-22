# frozen_string_literal: true

require_relative '../../support/feature_helper'
require_relative '../../../lib/license_finder/platform'

describe 'Conda' do
  # As a Python developer who uses Conda
  # I want to be able to manage Conda dependencies

  let(:conda_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::CondaProject.create
    conda_developer.run_license_finder
    expect(conda_developer).to be_seeing_line 'zlib, 1.2.11, "zlib/libpng license"'
  end
end
