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
  dependencies = {
    "mvn" => "Maven",
    "npm" => "NPM",
    "pip" => "Pip",
    "gradle" => "Gradle",
    "bower" => "Bower",
    "rebar" => "Rebar",
    "godep" => "Go"
  }
  dependencies["pod"] = "Cocoapods" if LicenseFinder::Platform.darwin?
  satisfied = true
  dependencies.each do |dependency, description|
    printf "checking dev dependency for #{description} ... "
    if LicenseFinder::Platform.windows?
      `where #{dependency} 2>NUL`
    else
      `which #{dependency} 2>/dev/null`
    end
    status = $?
    if status.success?
      puts "OK"
    else
      puts "missing `#{dependency}`"
      satisfied = false
    end
  end
  exit 1 unless satisfied
end

task :spec     => :check_dependencies
task :features => :check_dependencies

task :default => [:spec, :features]
