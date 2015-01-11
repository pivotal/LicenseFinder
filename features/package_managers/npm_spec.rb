require 'feature_helper'

describe "Node Dependencies" do
  # As a Node developer
  # I want to be able to manage NPM dependencies

  let(:user) { LicenseFinder::TestingDSL::User.new }

  specify "are shown in reports" do
    user.create_node_app
    user.run_license_finder
    expect(user).to be_seeing_line "http-server, 0.6.1, MIT"
  end
end
