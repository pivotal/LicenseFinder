namespace :license do
  desc 'generate a list of dependency licenses'
  task :generate_dependencies do
    LicenseFinder.write_files
  end

  desc 'action items'
  task :action_items => :generate_dependencies do
    puts "Dependencies that need approval:"
    puts LicenseFinder.action_items
  end
end
