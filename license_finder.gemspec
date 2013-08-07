require './lib/license_finder/platform'

Gem::Specification.new do |s|
  s.name        = "license_finder"
  s.version     = "0.9.1"
  s.authors     = ["Jacob Maine", "Matthew Kane Parker", "Ian Lesperance", "David Edwards", "Paul Meskers", "Brent Wheeldon", "Trevor John", "David Tengdin", "William Ramsey"]
  s.email       = ["licensefinder@pivotalabs.com"]
  s.homepage    = "https://github.com/pivotal/LicenseFinder"
  s.summary     = "Audit the OSS licenses of your application's dependencies."

  s.description = <<-DESCRIPTION
  Do you know the licenses of all your application's dependencies? What open source software licenses will your business accept?

  LicenseFinder culls your Gemfile, detects the licenses of the gems in it, and gives you a report that you can act on. If you already know
  what licenses your business is comfortable with, you can whitelist them, leaving you with an action report of only those dependencies that have
  licenses that fall outside of the whitelist.
  DESCRIPTION

  s.license     = "MIT"

  s.add_dependency "bundler"
  s.add_dependency "sequel"
  s.add_dependency "thor"
  s.add_dependency "rake"
  s.add_dependency "httparty"
  s.add_dependency LicenseFinder::Platform.sqlite_gem

  %w(rspec xpath cucumber pry).each do |gem|
    s.add_development_dependency gem
  end

  s.add_development_dependency "capybara", "~> 2.0.0"
  s.add_development_dependency "rails", "~> 3.2.0"
  s.add_development_dependency "webmock", "~> 1.13"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.platform = "java" if LicenseFinder::Platform.java?
end
