# frozen_string_literal: true

require_relative '../../support/feature_helper'
describe 'Go Modules Dependencies' do
  let(:go_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports for a project' do
    LicenseFinder::TestingDSL::GoModulesProject.create
    go_developer.run_license_finder('go_modules')
    expect(go_developer).to be_seeing_line 'gopkg.in/check.v1, v0.0.0-20161208181325-20d25e280405, "Simplified BSD"'
    expect(go_developer).to be_seeing_line 'gopkg.in/yaml.v2, v2.2.8, "Apache 2.0, MIT"'
    expect(go_developer).to be_seeing_line 'github.com/gregjones/httpcache, v0.0.0-20190611155906-901d90724c79, MIT'
  end
end
