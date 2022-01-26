# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Pubspec Dependencies' do
  # As a developer on Flutter platform
  # I want to be able to manage Pub Package Manager dependencies

  let(:flutter_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::FlutterProject.create
    flutter_developer.run_license_finder
    expect(flutter_developer).to be_seeing_line 'device_info, 2.0.3, "New BSD"'
  end
end
