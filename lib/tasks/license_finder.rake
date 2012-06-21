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

  desc 'All gems approved for use'
  task 'action_items:ok' => :generate_dependencies do
    found = LicenseFinder::Finder.new.action_items
    if found.size > 0
      puts "Dependencies that need approval:"
      puts found
    else
      puts "All gems are approved for use"
    end
    exit 1 unless found.size == 0
  end
end
