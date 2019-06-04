# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Prepare Step' do
  let(:developer) { LicenseFinder::TestingDSL::User.new }

  context 'with project with invalid dependency' do
    specify 'it should throw an error' do
      LicenseFinder::TestingDSL::NpmProjectWithInvalidDependency.create
      developer.execute_command 'license_finder --prepare'

      expect(developer).to_not be_receiving_exit_code(0)
    end
  end

  context 'with --prepare-no-fail option specified' do
    specify 'it should not throw an error' do
      LicenseFinder::TestingDSL::NpmProjectWithInvalidDependency.create
      developer.execute_command 'license_finder --prepare-no-fail'

      expect(developer).to be_receiving_exit_code(0)
    end
  end
end
