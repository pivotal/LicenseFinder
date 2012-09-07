Gem::Specification.new do |s|
  s.name        = "license_finder"
  s.version     = File.read "VERSION"
  s.platform    = Gem::Platform::RUBY
  s.email       = ["jacob.maine@gmail.com"]
  s.authors     = ["Jacob Maine", "Matthew Kane Parker", "Ian Lesperance", "David Edwards"]
  s.homepage    = "https://github.com/pivotal/LicenseFinder"
  s.summary     = %q{License finding heaven.}
  s.description = %q{Find and display licenses of a project's gem dependencies.}
  s.license     = "MIT"

  s.add_development_dependency 'rspec', '~>2.3'
  s.add_development_dependency 'rr'
  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end
