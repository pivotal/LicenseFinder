require 'bundler'
Bundler::GemHelper.install_tasks

require './lib/license_finder/platform'
require 'rspec/core/rake_task'

desc 'Run all specs in spec/'
task :spec do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.fail_on_error = true
    t.pattern = './spec/**/*_spec.rb'
    t.rspec_opts = %w[--color]
  end
end

desc 'Only run cocoapods specs'
RSpec::Core::RakeTask.new('spec:cocoapods') do |t|
  t.fail_on_error = true
  t.pattern = './spec/lib/license_finder/package_managers/cocoa_pods_*spec.rb'
  t.rspec_opts = %w[--color]
end

desc 'Run all specs in features/'
task :features do
  RSpec::Core::RakeTask.new(:features) do |t|
    t.fail_on_error = true
    t.pattern = './features/**/*_spec.rb'
    opts = %w[--color --format d]
    opts += LicenseFinder::Platform.darwin? ? [] : %w[--tag ~ios]
    t.rspec_opts = opts
  end
end

desc 'Check for non-Ruby development dependencies.'
task :check_dependencies do
  require './lib/license_finder'
  satisfied = true
  LicenseFinder::Scanner::PACKAGE_MANAGERS.each do |package_manager|
    satisfied = false unless package_manager.installed?(LicenseFinder::Logger.new(LicenseFinder::Logger::MODE_INFO))
  end
  STDOUT.flush
  exit 1 unless satisfied
end

desc 'Configure ci pipeline'
task :update_pipeline, [:slack_url, :slack_channel] do |_, args|
  slack_url = args[:slack_url]
  slack_channel = args[:slack_channel]

  unless slack_url || slack_channel
    puts 'Warning: skipping slack notifications setup'
    puts 'Warning: You should provide slack channel and url to receive slack notifications on build failures'
  end

  params = []
  params << "slack_url=#{slack_url}" if slack_url
  params << "slack_channel=#{slack_channel}" if slack_channel

  vars = params.join(' ')
  cmd = "bash -c \"fly -t osl set-pipeline -n -p LicenseFinder --config <(erb #{vars} ci/pipelines/pipeline.yml.erb)\""

  system(cmd)
end

desc 'Configure release pipeline'
task :update_release_pipeline do
  cmd = 'bash -c "fly -t osl set-pipeline -n -p LicenseFinder-release --config ci/pipelines/release.yml"'

  system(cmd)
end

task spec: :check_dependencies
task features: :check_dependencies

task default: %i[spec features]
