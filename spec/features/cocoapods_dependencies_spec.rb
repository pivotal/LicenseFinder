require 'spec_helper'
require './features/step_definitions/testing_dsl'

describe "CocoaPods Dependencies" do
  # As a Mac developer
  # I want to be able to manage CocoaPods dependencies

  let(:user) { LicenseFinder::TestingDSL::User.new }

  specify "are shown in reports" do
    user.create_cocoapods_app
    user.run_license_finder
    expect(user).to be_seeing_line "ABTest, 0.0.5, MIT"
  end
end
