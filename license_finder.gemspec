# frozen_string_literal: true

version = File.read(File.expand_path('VERSION', __dir__)).strip

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.3.3'
  s.name        = 'license_finder'
  s.version     = version

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
  s.add_dependency 'rubyzip', '>=1', '<3'
  s.add_dependency 'thor'
  s.add_dependency 'toml', '0.2.0'
  s.add_dependency 'with_env', '1.1.0'
  s.add_dependency 'xml-simple'

  s.add_development_dependency 'addressable', '2.7.0'
  s.add_development_dependency 'capybara', '~> 3.15.0'
  s.add_development_dependency 'cocoapods', '>= 1.0.0' if RUBY_PLATFORM =~ /darwin/
  s.add_development_dependency 'fakefs', '~> 0.20.0'
  s.add_development_dependency 'mime-types', '3.3'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'rubocop', '~> 0.77.0'
  s.add_development_dependency 'rubocop-performance', '~> 1.5.0'
  s.add_development_dependency 'webmock', '~> 3.5'

  s.add_development_dependency 'rack', '> 1.6'
  s.add_development_dependency 'rack-test', '> 0.7'

  s.files         = `git ls-files`.split("\n").reject { |f| f.start_with?('spec', 'features') }
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
end
