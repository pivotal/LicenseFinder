require 'bundler'
Bundler::GemHelper.install_tasks

require './lib/license_finder/platform'
require 'rspec/core/rake_task'

desc "Run all specs in spec/"
task :spec do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.fail_on_error = true
    t.pattern = "./spec/**/*_spec.rb"
    t.rspec_opts = %w[--color]
  end
end

desc "Run all specs in features/"
task :features do
  RSpec::Core::RakeTask.new(:features) do |t|
    t.fail_on_error = true
    t.pattern = "./features/**/*_spec.rb"
    opts = %w[--color --format d]
    opts += LicenseFinder::Platform.darwin? ? [] : %w[--tag ~ios]
    t.rspec_opts = opts
  end
end

desc "Check for non-Ruby development dependencies."
task :check_dependencies do
  require './lib/license_finder'
  satisfied = true
  LicenseFinder::PackageManager.package_managers.each do |package_manager|
    satisfied = false unless package_manager.installed?(LicenseFinder::Logger.new(debug:true))
  end
  STDOUT.flush
  exit 1 unless satisfied
end

desc "Configure ci pipeline"
task :update_pipeline, [:slack_url, :slack_channel, :github_access_token] do |_, args|
  access_token = args[:github_access_token]
  slack_url = args[:slack_url]
  slack_channel = args[:slack_channel]

  unless access_token
    puts 'Warning: You should provide a Github access token with repo:status permission if you want to avoid rate limiting'
  end

  if !(slack_url || slack_channel)
    puts 'Warning: skipping slack notifications setup'
    puts 'Warning: You should provide slack channel and url to receive slack notifications on build failures'
  end

  params = []
  params << "slack_url=#{slack_url}" if slack_url
  params << "slack_channel=#{slack_channel}" if slack_channel
  params << "github_access_token=#{access_token}" if access_token

  vars = params.join(' ')
  cmd = "bash -c \"fly -t osl set-pipeline -n -p LicenseFinder --config <(erb #{vars} ci/pipelines/pipeline.yml.erb)\""

  system(cmd)
end

task :spec     => :check_dependencies
task :features => :check_dependencies

task :default => [:spec, :features]
