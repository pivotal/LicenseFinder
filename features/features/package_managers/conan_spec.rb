# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Conan Dependencies' do
  let(:conan_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports for a project' do
    LicenseFinder::TestingDSL::ConanProject.create
    conan_developer.run_license_finder
    expect(conan_developer).to be_seeing_line 'range-v3, 0.3.0, MIT'
  end
end
