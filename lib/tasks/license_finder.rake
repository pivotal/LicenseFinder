namespace :license do
  desc 'generate a list of dependency licenses'
  task :generate_dependencies do
    LicenseFinder.write_files
  end
end
