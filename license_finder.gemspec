lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'license_finder/platform'
require 'license_finder/version'

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 1.9.3'
  s.name        = "license_finder"
  s.version     = LicenseFinder::VERSION

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

  s.email       = ["labs-commoncode@pivotal.io"]
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
  s.add_dependency "thor"
  s.add_dependency "httparty"
  s.add_dependency "xml-simple"
  s.add_dependency "rubyzip"
  # to preserve ruby 1.9.3 support
  s.add_dependency 'with_env', ((RUBY_VERSION <= '1.9.3') ? '1.0.0' : '> 1.1')

  s.add_development_dependency "capybara", "~> 2.0.0"
  s.add_development_dependency "cocoapods", "0.34.0" if LicenseFinder::Platform.darwin?
  s.add_development_dependency "fakefs", "~> 0.6.7"
  s.add_development_dependency "pry"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "rspec-its"
  s.add_development_dependency "webmock", "~> 1.13"

  # to preserve ruby < 2.2.2 support.
  s.add_development_dependency 'rack', ((RUBY_VERSION < '2.2.2') ? '1.6.0' : '> 1.6')

  # temporary to preserve ruby 1.9.3 support.
  s.add_development_dependency "mime-types", "< 3.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end
