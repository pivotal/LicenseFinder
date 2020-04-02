# frozen_string_literal: true

version = File.read(File.expand_path('VERSION', __dir__)).strip

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.3.3'
  s.name        = 'license_finder'
  s.version     = version

  s.authors = [
    'Ryan Collins',
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
    'Mike Dalessio',
    'Jeff Jun'
  ]

  s.email       = ['labs-commoncode@pivotal.io']
  s.homepage    = 'https://github.com/pivotal/LicenseFinder'
  s.summary     = "Audit the OSS licenses of your application's dependencies."

  s.description = <<-DESCRIPTION
    LicenseFinder works with your package managers to find
    dependencies, detect the licenses of the packages in them, compare
    those licenses against a user-defined list of permitted licenses,
    and give you an actionable exception report.
  DESCRIPTION

  s.license = 'MIT'

  s.add_dependency 'bundler'
  s.add_dependency 'rubyzip', '>=1', '<3'
  s.add_dependency 'thor', '~> 1.0.1'
  s.add_dependency 'tomlrb', '~> 1.3.0'
  s.add_dependency 'with_env', '1.1.0'
  s.add_dependency 'xml-simple', '~> 1.1.5'

  s.add_development_dependency 'addressable', '2.7.0'
  s.add_development_dependency 'capybara', '~> 3.15.0'
  s.add_development_dependency 'cocoapods', '>= 1.0.0' if RUBY_PLATFORM =~ /darwin/
  s.add_development_dependency 'fakefs', '~> 1.2.0'
  s.add_development_dependency 'mime-types', '3.3.1'
  s.add_development_dependency 'pry', '~> 0.13.0'
  s.add_development_dependency 'rake', '~> 13.0.1'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rspec-its', '~> 1.3.0'
  s.add_development_dependency 'rubocop', '~> 0.81.0'
  s.add_development_dependency 'rubocop-performance', '~> 1.5.0'
  s.add_development_dependency 'webmock', '~> 3.5'

  s.add_development_dependency 'rack', '~> 2.2.2'
  s.add_development_dependency 'rack-test', '~> 1.1.0', '> 0.7'

  s.files         = `git ls-files`.split("\n").reject { |f| f.start_with?('spec', 'features') }
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
end
