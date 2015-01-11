require 'feature_helper'

describe "CocoaPods Dependencies", ios: true do
  # As a Mac developer
  # I want to be able to manage CocoaPods dependencies

  let(:user) { LicenseFinder::TestingDSL::User.new }

  specify "are shown in reports" do
    LicenseFinder::TestingDSL::CocoaPodsProject.create
    user.run_license_finder
    expect(user).to be_seeing_line "ABTest, 0.0.5, MIT"
  end
end
