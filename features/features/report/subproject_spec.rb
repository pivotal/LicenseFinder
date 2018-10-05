# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Aggregate Paths Projects report' do
  # As a non-technical product owner
  # I want a single csv report that includes multiple sub-projects
  # So that I can easily review my composite application's dependencies and licenses

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  specify 'shows specified columns' do
    foo10 = developer.create_gem_in_path('foo', 'v-10', version: '1.0.0', license: 'MIT', homepage: 'http://example.homepage.com')

    project1 = developer.create_ruby_app('project_1')
    project1.depend_on(foo10)

    developer.create_empty_project
    developer.execute_command("license_finder report --columns name homepage aggregate_paths --aggregate_paths #{project1.project_dir} --format=csv")
    expect(developer).to be_seeing_once("foo,http://example.homepage.com,#{project1.project_dir}")
  end

  specify 'shows dependencies for multiple projects' do
    project1 = developer.create_ruby_app('project_1')
    project1.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))

    project2 = developer.create_ruby_app('project_2')
    project2.depend_on(developer.create_gem('bar', version: '2.0.0', license: 'GPLv2'))

    developer.create_empty_project
    developer.execute_command("license_finder report --columns name version licenses aggregate_paths --aggregate_paths #{project1.project_dir} #{project2.project_dir} --format=csv")
    expect(developer).to be_seeing("foo,1.0.0,MIT,#{project1.project_dir}")
    expect(developer).to be_seeing("bar,2.0.0,GPLv2,#{project2.project_dir}")
  end

  specify 'shows duplicate dependencies only once, with list of project_paths' do
    foo = developer.create_gem('foo', version: '1.0.0', license: 'MIT')

    project1 = developer.create_ruby_app('project_1')
    project1.depend_on(foo)

    project2 = developer.create_ruby_app('project_2')
    project2.depend_on(foo)

    developer.create_empty_project
    developer.execute_command("license_finder report --columns name version licenses aggregate_paths --aggregate_paths #{project1.project_dir} #{project2.project_dir} --format=csv")
    expect(developer).to be_seeing_once("foo,1.0.0,MIT,\"#{project1.project_dir},#{project2.project_dir}\"")
  end

  specify 'does not mark dependencies with different versions as duplicates' do
    foo10 = developer.create_gem_in_path('foo', 'v-10', version: '1.0.0', license: 'MIT')
    foo11 = developer.create_gem_in_path('foo', 'v-11', version: '1.1.0', license: 'MIT')

    project1 = developer.create_ruby_app('project_1')
    project1.depend_on(foo10)

    project2 = developer.create_ruby_app('project_2')
    project2.depend_on(foo11)

    developer.create_empty_project
    developer.execute_command("license_finder report --columns name version licenses aggregate_paths --aggregate_paths #{project1.project_dir} #{project2.project_dir} --format=csv")
    expect(developer).to be_seeing_once("foo,1.0.0,MIT,#{project1.project_dir}")
    expect(developer).to be_seeing_once("foo,1.1.0,MIT,#{project2.project_dir}")
  end
end
