require 'bundler'
Bundler::GemHelper.install_tasks

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
  t.cucumber_opts = "features --format pretty"
end

task :default => [:spec, :features]
