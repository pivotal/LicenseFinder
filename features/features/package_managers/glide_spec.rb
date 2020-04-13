# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Glide Dependencies' do
  let(:go_developer) { LicenseFinder::TestingDSL::User.new }

  context 'when project is in src directory' do
    specify 'are shown in reports for a project' do
      LicenseFinder::TestingDSL::GlideProject.create

      go_developer.run_license_finder('src/gopath_glide/src')
      expect(go_developer).to be_seeing_line 'github.com/Masterminds/semver, 517734cc7d6470c0d07130e40fd40bdeb9bcd3fd, MIT'
      expect(go_developer).to be_seeing_line 'github.com/Masterminds/cookoo, 78aa11ce75e257c51be7ea945edb84cf19c4a6de, MIT'
    end
  end

  context 'when project in root directory' do
    specify 'are shown in reports for a project' do
      LicenseFinder::TestingDSL::GlideProjectWithoutSrc.create

      go_developer.run_license_finder('src/gopath_glide_without_src')
      expect(go_developer).to be_seeing_line 'github.com/Masterminds/semver, 517734cc7d6470c0d07130e40fd40bdeb9bcd3fd, MIT'
      expect(go_developer).to be_seeing_line 'github.com/Masterminds/cookoo, 78aa11ce75e257c51be7ea945edb84cf19c4a6de, MIT'
    end
  end

  context 'when project in both root and src directory' do
    specify 'are shown in reports for a project' do
      LicenseFinder::TestingDSL::GlideProjectWithRootAndSrc.create

      go_developer.run_license_finder('src/gopath_glide_in_root_and_src')
      expect(go_developer).to be_seeing_line 'github.com/Masterminds/semver, 517734cc7d6470c0d07130e40fd40bdeb9bcd3fd, MIT'
      expect(go_developer).to be_seeing_line 'github.com/Masterminds/cookoo, 78aa11ce75e257c51be7ea945edb84cf19c4a6de, MIT'

      go_developer.run_license_finder('src/gopath_glide_in_root_and_src/src')
      expect(go_developer).to be_seeing_line 'github.com/googollee/go-socket.io, 5447e71f36d394766bf855d5714a487596809f0d, unknown'
      expect(go_developer).to be_seeing_line 'github.com/gorilla/mux, bcd8bc72b08df0f70df986b97f95590779502d31, "New BSD"'
    end
  end
end
