# frozen_string_literal: true

require_relative '../../support/feature_helper'
require_relative '../../../lib/license_finder/version'

describe 'Bundler Dependencies' do
  around do |example|
    # Run license_finder outside any Bundler environment
    ::Bundler.with_unbundled_env do
      example.run
    end
  end

  let(:bundler_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::BundlerProject.create
    bundler_developer.run_license_finder
    expect(bundler_developer).to be_seeing_something_like /bundler.*MIT/
  end

  specify 'works with vendored bundle' do
    LicenseFinder::TestingDSL::VendorBundlerProject.create
    puts 'bundler project created'
    bundler_developer.run_license_finder
    expect(bundler_developer).to be_seeing_something_like /rake.*MIT/
  end

  specify 'works with git dependency running outside of the bundle' do
    # Fake home to avoid polluting real home with git checkout
    ENV['HOME'] = LicenseFinder::TestingDSL::Paths.projects.to_s
    LicenseFinder::TestingDSL::GitBundlerProject.create
    puts 'bundler project created'
    bundler_developer.run_license_finder
    expect(bundler_developer).to be_seeing_something_like /bundler.*MIT/
  end
end
