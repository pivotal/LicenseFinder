namespace :license do
  desc 'generate a list of dependecy licenses'
  task :check_dependencies do
    LicenseFinder.from_bundler.each { |lf| puts lf.to_s(ARGV.first == "--with-licenses") }
  end
end
