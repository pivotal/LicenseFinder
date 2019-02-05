# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Nuget Dependencies' do
  # As a .NET developer
  # I want to be able to manage Nuget dependencies

  let(:dotnet_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::NugetProject.create
    dotnet_developer.run_license_finder 'nuget'
    expect(dotnet_developer).to be_seeing_line 'NUnit, 2.6.4, unknown'
  end
end
