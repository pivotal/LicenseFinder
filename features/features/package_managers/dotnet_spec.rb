# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Dotnet dependencies' do
  let(:dotnet_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::DotnetProject.create
    dotnet_developer.run_license_finder 'dotnet'
    expect(dotnet_developer).to be_seeing_line 'Microsoft.AspNet.WebApi.Client, 5.2.6, http://www.microsoft.com/web/webpi/eula/net_library_eula_ENU.htm'
  end
end
