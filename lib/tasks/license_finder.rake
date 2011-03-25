namespace :license do
  desc 'write out example config file'
  task :init do
    FileUtils.cp(File.join(File.dirname(__FILE__), '..', '..', 'files', 'license_finder.yml'), './config/license_finder.yml')
  end

  desc 'generate a list of dependency licenses'
  task :generate_dependencies do
    LicenseFinder::Finder.new.write_files
  end

  desc 'action items'
  task :action_items => :generate_dependencies do
    puts "Dependencies that need approval:"
    puts LicenseFinder::Finder.new.action_items
  end
end
