namespace :license do
  desc 'generate a list of dependecy licenses'
  task :check_dependencies do
    LicenseFinder.to_yml
  end
end
