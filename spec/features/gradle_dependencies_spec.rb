require 'spec_helper'
require './features/step_definitions/testing_dsl'

describe "Gradle Dependencies" do
  # As a Java developer
  # I want to be able to manage Gradle dependencies

  let(:user) { LicenseFinder::TestingDSL::User.new }

  specify "are shown in reports" do
    user.create_gradle_app
    user.run_license_finder
    expect(user).to be_seeing_line 'junit, 4.11, "Common Public License Version 1.0"'
  end
end
