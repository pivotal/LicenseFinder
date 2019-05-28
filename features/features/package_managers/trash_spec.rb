# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Trash Dependencies' do
  let(:go_developer) { LicenseFinder::TestingDSL::User.new }

  context 'when the project does not contain trash.lock' do
    context 'when the project is not run with prepare' do
      specify 'fails to fetch the dependencies' do
        LicenseFinder::TestingDSL::TrashProject.create
        _output, status = go_developer.run_license_finder('gopath_trash')

        expect(status).to eq 1
        expect(go_developer).to_not be_seeing_something_like %r{github.com/Masterminds/vcs}
        expect(go_developer).to_not be_seeing_something_like %r{gopkg.in/yaml.v2}
      end
    end

    context 'when the project is run with prepare' do
      specify 'shows dependencies in reports' do
        LicenseFinder::TestingDSL::TrashProject.create
        go_developer.run_license_finder('gopath_trash', '-p')

        expect(go_developer).to be_seeing_line 'github.com/Masterminds/vcs, v1.12.0, MIT'
        expect(go_developer).to be_seeing_line 'gopkg.in/yaml.v2, eb3733d160e74a9c7e442f435eb3bea458e1d19f, "Apache 2.0, MIT"'
      end
    end
  end

  context 'when the project contains trash.lock' do
    context 'when the project is not run with prepare' do
      specify 'shows dependencies in reports without license information' do
        LicenseFinder::TestingDSL::TrashProject.create
        go_developer.run_license_finder('gopath_trash')

        expect(go_developer).to_not be_seeing_line 'github.com/Masterminds/vcs, v1.12.0, unknown'
        expect(go_developer).to_not be_seeing_line 'gopkg.in/yaml.v2, eb3733d160e74a9c7e442f435eb3bea458e1d19f, unknown'
      end
    end

    context 'when the project is run with prepare' do
      specify 'shows dependencies in reports' do
        LicenseFinder::TestingDSL::PreparedTrashProject.create
        go_developer.run_license_finder('gopath_trash_prepared', '-p')

        expect(go_developer).to be_seeing_line 'github.com/Masterminds/vcs, v1.12.0, MIT'
        expect(go_developer).to be_seeing_line 'gopkg.in/yaml.v2, eb3733d160e74a9c7e442f435eb3bea458e1d19f, "Apache 2.0, MIT"'
      end
    end
  end
end
