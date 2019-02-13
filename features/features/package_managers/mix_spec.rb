# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Mix Dependencies' do
  # As an Elixir developer
  # I want to be able to manage Mix dependencies

  let(:elixir_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::MixProject.create
    puts 'mix project created'
    elixir_developer.run_license_finder
    expect(elixir_developer).to be_seeing_line 'fs, 0.9.1, MIT'
    expect(elixir_developer).to be_seeing_line 'uuid, 1.1.5, "Apache 2.0"'
    expect(elixir_developer).to be_seeing_line 'plug, 1.7.2, "Apache 2.0"'
  end

  specify 'do not include in_umbrella: true dependencies internal to an umbrella project' do
    LicenseFinder::TestingDSL::MixUmbrellaProject.create
    puts 'mix umbrella project created'
    elixir_developer.run_license_finder
    expect(elixir_developer).not_to be_seeing_something_like /awesome/
    expect(elixir_developer).to be_seeing_line 'fs, 0.9.1, MIT'
    expect(elixir_developer).to be_seeing_line 'uuid, 1.1.5, "Apache 2.0"'
    expect(elixir_developer).to be_seeing_line 'plug, 1.7.2, "Apache 2.0"'
  end
end
