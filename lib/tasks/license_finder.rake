desc 'Audit your Gemfile for software licenses. This is the same as running `license_finder` in the terminal.'
task :license_finder do
  puts "DEPRECATION WARNING: 'rake license_finder' is going to be removed 
  for the 1.0.0 release. Please instead use the command line utility 'license_finder'
  or refer to the README for avalible command line utilities"
  LicenseFinder::CLI::Main.new.rescan
end
