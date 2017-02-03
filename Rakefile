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
task :update_pipeline do
  cmd = 'bash -c "fly -t osl set-pipeline -n -p LicenseFinder --config <(erb ci/pipelines/pipeline.yml.erb)"'
  system(cmd)
end
task :spec     => :check_dependencies
task :features => :check_dependencies

task :default => [:spec, :features]
