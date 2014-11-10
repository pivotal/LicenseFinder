require './lib/license_finder/platform'

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 1.9.3'
  s.name        = "license_finder"
  s.version     = "1.1.1"

  s.authors = [
    "Jacob Maine",
    "Matthew Kane Parker",
    "Ian Lesperance",
    "David Edwards",
    "Paul Meskers",
    "Brent Wheeldon",
    "Trevor John",
    "David Tengdin",
    "William Ramsey",
    "David Dening",
    "Geoff Pleiss",
    "Mike Chinigo",
    "Mike Dalessio"
  ]

  s.email       = ["commoncode@pivotalabs.com"]
  s.homepage    = "https://github.com/pivotal/LicenseFinder"
  s.summary     = "Audit the OSS licenses of your application's dependencies."

  s.description = <<-DESCRIPTION
    LicenseFinder works with your package managers to find
    dependencies, detect the licenses of the packages in them, compare
    those licenses against a user-defined whitelist, and give you an
    actionable exception report.
  DESCRIPTION

  s.license     = "MIT"

  s.add_dependency "bundler"
  s.add_dependency "sequel"
  s.add_dependency "thor"
  s.add_dependency "httparty"
  s.add_dependency "xml-simple"
  s.add_dependency LicenseFinder::Platform.sqlite_gem

  s.add_development_dependency rake
  s.add_development_dependency rspec-its
  s.add_development_dependency xpath
  s.add_development_dependency cucumber
  s.add_development_dependency pry
  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "capybara", "~> 2.0.0"
  s.add_development_dependency "webmock", "~> 1.13"
  s.add_development_dependency "cocoapods" if LicenseFinder::Platform.darwin?

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.platform = "java" if LicenseFinder::Platform.java?
end
