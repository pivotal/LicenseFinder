# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Maven Dependencies' do
  # As a Java developer
  # I want to be able to manage Maven dependencies

  let(:java_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::MavenProject.create
    java_developer.run_license_finder
    expect(java_developer).to be_seeing_line 'junit, 4.11, "Common Public License Version 1.0"'
  end

  context 'when using --maven_include_groups flag' do
    it 'shows the groupid' do
      LicenseFinder::TestingDSL::MavenProject.create
      java_developer.run_license_finder nil, '--maven_include_groups'
      expect(java_developer).to be_seeing_line 'junit:junit, 4.11, "Common Public License Version 1.0"'
    end
  end
end
