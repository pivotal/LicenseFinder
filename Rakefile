# frozen_string_literal: true

require 'bundler'
Bundler::GemHelper.install_tasks

require './lib/license_finder/platform'
require 'rspec/core/rake_task'

desc 'Run all specs in spec/'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = true
  t.pattern = './spec/**/*_spec.rb'
  t.rspec_opts = %w[--color]
end

namespace :features do
  desc 'Run test tagged \'focus\''
  RSpec::Core::RakeTask.new(:focus) do |t|
    t.fail_on_error = true
    t.pattern = './features/**/*_spec.rb'
    opts = %w[--color --format d --tag focus]
    opts += LicenseFinder::Platform.darwin? ? [] : %w[--tag ~ios]
    t.rspec_opts = opts
  end
end

desc 'Run all specs in features/'
RSpec::Core::RakeTask.new(:features) do |t|
  t.fail_on_error = true
  t.pattern = './features/**/*_spec.rb'
  opts = %w[--color --format d]
  opts += LicenseFinder::Platform.darwin? ? [] : %w[--tag ~ios]
  t.rspec_opts = opts
end

desc 'Check for non-Ruby development dependencies.'
task :check_dependencies do
  require './lib/license_finder'
  satisfied = true
  LicenseFinder::Scanner::PACKAGE_MANAGERS.each do |package_manager|
    satisfied = false unless package_manager.new(project_path: Pathname.new('')).installed?(LicenseFinder::Logger.new(LicenseFinder::Logger::MODE_INFO))
  end
  STDOUT.flush
  exit 1 unless satisfied
end

desc 'Configure LF and LF PR pipeline'
task :update_pipeline, [:slack_url, :slack_channel] do |_, args|
  slack_url = args[:slack_url]
  slack_channel = args[:slack_channel]

  unless slack_url || slack_channel
    puts 'Warning: skipping slack notifications setup'
    puts 'Warning: You should provide slack channel and url to receive slack notifications on build failures'
  end

  ruby_versions = %w[2.7.1 2.6.5 2.5.7 2.4.9 2.3.8 jruby-9.2.14.0]

  params = []
  params << "ruby_versions=#{ruby_versions.join(',')}"
  params << "slack_url=#{slack_url}" if slack_url
  params << "slack_channel=#{slack_channel}" if slack_channel

  vars = params.join(' ')

  cmd = "bash -c \"fly -t osl set-pipeline -n -p LicenseFinder --config <(erb #{vars} ci/pipelines/release.yml.erb)\""
  system(cmd)

  cmd = "bash -c \"fly -t osl set-pipeline -n -p LicenseFinder-pr --config <(erb #{vars} ci/pipelines/pull-request.yml.erb)\""
  system(cmd)
end

task default: %i[spec features]
task spec: :check_dependencies
task features: :check_dependencies
task 'spec:focus': :check_dependencies
task 'features:focus': :check_dependencies
