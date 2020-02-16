# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Erlangmk Dependencies' do
  # As an Erlang developer
  # I want to be able to manage dependencies via Erlang.mk

  let(:erlang_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::ErlangMkProject.create
    puts 'Erlang.mk project created'
    erlang_developer.run_license_finder
    expect(erlang_developer).to be_seeing_line 'fs, 0.9.1, MIT'
    expect(erlang_developer).to be_seeing_line 'uuid, 1.1.5, "Apache 2.0"'
    expect(erlang_developer).to be_seeing_line 'plug, 1.7.2, "Apache 2.0"'
  end
end
