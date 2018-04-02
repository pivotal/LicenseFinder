lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'license_finder/platform'
require 'license_finder/version'

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.1.0'
  s.name        = 'license_finder'
  s.version     = LicenseFinder::VERSION

  s.authors = [
    'Ryan Collins',
    'Vikram Yadav',
    'Daniil Kouznetsov',
    'Andy Shen',
    'Shane Lattanzio',
    'Li Sheng Tai',
    'Vlad vassilovski',
    'Jacob Maine',
    'Matthew Kane Parker',
    'Ian Lesperance',
    'David Edwards',
    'Paul Meskers',
    'Brent Wheeldon',
    'Trevor John',
    'David Tengdin',
    'William Ramsey',
    'David Dening',
    'Geoff Pleiss',
    'Mike Chinigo',
    'Mike Dalessio'
  ]

  s.email       = ['labs-commoncode@pivotal.io']
  s.homepage    = 'https://github.com/pivotal/LicenseFinder'
  s.summary     = "Audit the OSS licenses of your application's dependencies."

  s.description = <<-DESCRIPTION
    LicenseFinder works with your package managers to find
    dependencies, detect the licenses of the packages in them, compare
    those licenses against a user-defined whitelist, and give you an
    actionable exception report.
  DESCRIPTION

  s.license = 'MIT'

  s.add_dependency 'bundler'
  s.add_dependency 'httparty'
  s.add_dependency 'rubyzip'
  s.add_dependency 'thor'
  s.add_dependency 'toml', '0.2.0'
  s.add_dependency 'with_env', '1.1.0'
  s.add_dependency 'xml-simple'

  s.add_development_dependency 'addressable', '2.5.2'
  s.add_development_dependency 'capybara', '~> 2.0.0'
  s.add_development_dependency 'cocoapods', '0.34.0' if LicenseFinder::Platform.darwin?
  s.add_development_dependency 'fakefs', '~> 0.11.3'
  s.add_development_dependency 'mime-types', '3.1'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'webmock', '~> 1.13'

  # to preserve ruby < 2.2.2 support.
  s.add_development_dependency 'rack', (RUBY_VERSION < '2.2.2' ? '1.6.0' : '> 1.6')
  s.add_development_dependency 'rack-test', (RUBY_VERSION < '2.2.2' ? '0.7.0' : '> 0.7')

  s.files         = `git ls-files`.split("\n").reject { |f| f.start_with?('spec', 'features') }
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
end
