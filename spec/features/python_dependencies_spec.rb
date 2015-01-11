require 'spec_helper'
require './features/step_definitions/testing_dsl'

describe "Python Dependencies" do
  # As a Python developer
  # I want to be able to manage Python dependencies

  let(:user) { LicenseFinder::TestingDSL::User.new }

  specify "are shown in reports" do
    user.create_python_app
    user.run_license_finder
    expect(user).to be_seeing_line 'argparse, 1.2.1, "Python Software Foundation License"'
  end
end
