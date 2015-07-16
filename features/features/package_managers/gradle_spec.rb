require_relative '../../support/feature_helper'

describe 'Gradle Dependencies' do
  # As a Java developer
  # I want to be able to manage Gradle dependencies

  let(:java_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports for a single-module project' do
    LicenseFinder::TestingDSL::GradleProject.create
    java_developer.run_license_finder('single-module-gradle')
    expect(java_developer).to be_seeing_line 'junit, 4.11, "Common Public License Version 1.0"'
  end

  specify 'are shown in reports for a multi-module project' do
    LicenseFinder::TestingDSL::MultiModuleGradleProject.create
    java_developer.run_license_finder('multi-module-gradle')
    expect(java_developer).to be_seeing_line 'junit, 4.12, "Eclipse Public License 1.0"'
    expect(java_developer).to be_seeing_line 'mockito-core, 1.9.5, "The MIT License"'
  end
end
