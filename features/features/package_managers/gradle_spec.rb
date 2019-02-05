# frozen_string_literal: true

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
    LicenseFinder::TestingDSL::GradleProject::MultiModule.create
    java_developer.run_license_finder('multi-module-gradle')
    expect(java_developer).to be_seeing_line 'junit, 4.12, "Eclipse Public License 1.0"'
    expect(java_developer).to be_seeing_line 'mockito-core, 1.9.5, MIT'
  end

  specify 'show both file-based jars and downloaded dependencies' do
    LicenseFinder::TestingDSL::GradleProject::FileBasedLibs.create
    java_developer.run_license_finder('file-based-libs-gradle')
    expect(java_developer).to be_seeing_line 'data.json-0.2.3.jar, unknown, unknown'
    expect(java_developer).to be_seeing_line 'guava, 18.0, "Apache 2.0"'
  end

  specify 'are shown in reports for a project with an alternate build.gradle file' do
    LicenseFinder::TestingDSL::AlternateBuildFileGradleProject.create
    java_developer.run_license_finder('alternate-build-file-gradle')
    expect(java_developer).to be_seeing_line 'junit, 4.11, "Common Public License Version 1.0"'
  end

  specify 'are shown in reports for a project with an kotlin build.gradle.kts file' do
    LicenseFinder::TestingDSL::KtsBuildFileGradleProject.create
    java_developer.run_license_finder('kts-build-file-gradle')
    expect(java_developer).to be_seeing_line 'kotlin-stdlib, 1.2.61, "Apache 2.0"'
  end
end
