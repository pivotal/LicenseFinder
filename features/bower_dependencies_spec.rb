require 'feature_helper'

describe "Bower Dependencies" do
  # As a JS developer
  # I want to be able to manage Bower dependencies

  let(:user) { LicenseFinder::TestingDSL::User.new }

  specify "are shown in reports" do
    user.create_bower_app
    user.run_license_finder
    expect(user).to be_seeing_line "gmaps, 0.2.30, MIT"
  end
end
