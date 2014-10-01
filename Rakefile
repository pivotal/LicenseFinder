require 'bundler'
Bundler::GemHelper.install_tasks

require './lib/license_finder/platform'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'

desc "Run all specs in spec/"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = true
  t.pattern = "./spec/**/*_spec.rb"
  t.rspec_opts = %w[--color]
end

desc "Run all cukes in features/"
Cucumber::Rake::Task.new(:features) do |t|
  tags = LicenseFinder::Platform.darwin? ? "" : "--tags ~@ios"
  t.cucumber_opts = "features --format pretty #{tags}"
end

desc "Check for non-Ruby development dependencies."
task :check_dependencies do
  require "open3"

  dependencies = {
    "mvn" => "Maven",
    "npm" => "node.js",
    "pip" => "Python"
  }
  dependencies["pod"] = "Cocoapod" if LicenseFinder::Platform.darwin?
  satisfied = true
  dependencies.each do |dependency, description|
    stdout, stderr, status = Open3.capture3 "which #{dependency}"
    unless status.success?
      puts "Development dependency missing: `#{dependency}` for #{description}"
      satisfied = false
    end
  end
  exit 1 unless satisfied
end

task :spec     => :check_dependencies
task :features => :check_dependencies

task :default => [:spec, :features]
