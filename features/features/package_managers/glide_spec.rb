require_relative '../../support/feature_helper'

describe 'Glide Dependencies' do
  let(:go_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports for a project' do
    project = LicenseFinder::TestingDSL::GlideProject.create
    ENV['GOPATH'] = project.project_dir.to_s

    go_developer.run_license_finder
    expect(go_developer).to be_seeing_line 'github.com/Masterminds/semver, 517734cc7d6470c0d07130e40fd40bdeb9bcd3fd, MIT'
    expect(go_developer).to be_seeing_line 'github.com/Masterminds/cookoo, 78aa11ce75e257c51be7ea945edb84cf19c4a6de, MIT'
  end
end
