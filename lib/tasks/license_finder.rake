namespace :license do
  desc 'write out example config file'
  task :init do
    LicenseFinder::CLI.new.create_default_configuration
  end

  desc 'generate a list of dependency licenses'
  task :generate_dependencies => :init do
    puts "rake license:generate_dependencies is deprecated and will be removed in version 1.0. Use rake license:action_items instead."
    LicenseFinder::Reporter.new
  end

  desc 'action items'
  task :action_items => :init do
    LicenseFinder::CLI.new.check_for_action_items
  end

  desc 'return a failure status code for unapproved dependencies'
  task 'action_items:ok' => :init do
    puts "rake license:action_items:ok is deprecated and will be removed in version 1.0.  Use rake license:action_items instead."
    LicenseFinder::CLI.new.check_for_action_items
  end
end
