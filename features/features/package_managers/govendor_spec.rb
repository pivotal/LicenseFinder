# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Govendor Dependencies' do
  let(:go_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports for a project' do
    project = LicenseFinder::TestingDSL::GovendorProject.create
    ENV['GOPATH'] = "#{project.project_dir}/gopath_govendor"

    go_developer.run_license_finder('gopath_govendor/src')

    expect(go_developer).to be_seeing_line 'github.com/Bowery/prompt, 0f1139e9a1c74b57ccce6bdb3cd2f7cd04dd3449, MIT'
    expect(go_developer).to be_seeing_line 'github.com/dchest/safefile, 855e8d98f1852d48dde521e0522408d1fe7e836a, unknown'
  end
end
