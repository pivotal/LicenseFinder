desc 'Audit your Gemfile for software licenses. This is the same as running `license_finder` in the terminal.'
task :license_finder do
  LicenseFinder::CLI.check_for_action_items
end
