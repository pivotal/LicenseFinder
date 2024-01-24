# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Maven Dependencies' do
  # As a Java developer
  # I want to be able to manage Maven dependencies

  let(:java_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::MavenProject.create
    java_developer.run_license_finder
    expect(java_developer).to be_seeing_line 'junit, 4.13.1, "Eclipse Public License 1.0"'
  end

  context 'when using --maven_include_groups flag' do
    it 'shows the groupid' do
      LicenseFinder::TestingDSL::MavenProject.create
      java_developer.run_license_finder nil, '--maven_include_groups'
      expect(java_developer).to be_seeing_line 'junit:junit, 4.13.1, "Eclipse Public License 1.0"'
    end
  end

  it 'extracts name/description/url from POM and license/notice from JAR' do
    LicenseFinder::TestingDSL::MavenProject.create
    java_developer.execute_command 'license_finder report --columns summary description homepage texts notice --format=csv'

    expect(java_developer).to be_seeing_once 'Hamcrest Core,'
    expect(java_developer).to be_seeing_once 'This is the core API of hamcrest matcher framework'
    expect(java_developer).to be_seeing_once 'Copyright (c) 2000-2006, www.hamcrest.org'

    expect(java_developer).to be_seeing_once 'JUnit,'
    expect(java_developer).to be_seeing_once '"JUnit is a unit testing framework for Java'
    expect(java_developer).to be_seeing_once 'http://junit.org'

    expect(java_developer).to be_seeing_once 'Apache Commons Lang,"Apache Commons Lang, a package of Java utility classes'
    expect(java_developer).to be_seeing_once 'Version 2.0, January 2004' # LICENSE
    expect(java_developer).to be_seeing_once 'This product includes software developed at' # NOTICE
  end

  it 'extracts name for a package that is using the "jakarta" classifier' do
    LicenseFinder::TestingDSL::MavenProject.create
    java_developer.execute_command 'license_finder report --columns summary description homepage texts notice --format=csv'

    # the JAR file is named like "querydsl-jpa-5.0.0-jakarta.jar"
    expect(java_developer).to be_seeing_once 'Querydsl - JPA support'
  end

  it 'handles an empty dependencies section gracefully' do
    LicenseFinder::TestingDSL::MavenProjectNoDeps.create
    java_developer.run_license_finder
    expect(java_developer).to be_seeing_line 'No dependencies recognized!'
  end
end
