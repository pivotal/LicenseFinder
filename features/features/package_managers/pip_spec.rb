# frozen_string_literal: true

require_relative '../../support/feature_helper'
require_relative '../../../lib/license_finder/platform'

describe 'Pip Dependencies' do
  # As a Python developer
  # I want to be able to manage Pip dependencies

  let(:python_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::PipProject.create
    python_developer.run_license_finder
    expect(python_developer).to be_seeing_line 'rsa, 3.1.4, "ASL 2"'
  end

  context 'when there are platform markers' do
    context 'when platform markers match the current system OS' do
      it 'should show up in the report' do
        platform = if LicenseFinder::Platform.darwin?
                     'Darwin'
                   elsif LicenseFinder::Platform.windows?
                     'Windows'
                   else
                     'Linux' # Internal test uses Linux platform
                   end

        project = LicenseFinder::TestingDSL::PipProject.new
        project.add_dep_with_platform(platform)
        project.add_dep
        project.install
        python_developer.run_license_finder
        expect(python_developer).to be_seeing_line 'colorama, 0.3.9, BSD'
      end
    end

    context 'when platform markers do not match the current system OS' do
      it 'should not show up in the report' do
        project = LicenseFinder::TestingDSL::PipProject.new
        project.add_dep_with_platform('different-platform')
        project.add_dep
        project.install
        python_developer.run_license_finder
        expect(python_developer).to_not be_seeing_line 'colorama, 0.3.9, BSD'
      end
    end
  end
end
