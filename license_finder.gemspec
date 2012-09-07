Gem::Specification.new do |s|
  s.name        = "license_finder"
  s.version     = File.read "VERSION"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jacob Maine", "Matthew Kane Parker", "Ian Lesperance", "David Edwards"]
  s.email       = ["brent@pivotalabs.com"]
  s.homepage    = "https://github.com/pivotal/LicenseFinder"
  s.summary     = "Know your dependencies - and the licenses they are binding your application to."
  s.description = "Find and display licenses of a project's gem dependencies, so that you know what your limitations are when distributing your application."
  s.license     = "MIT"

  s.add_development_dependency 'rspec', '~>2.3'
  s.add_development_dependency 'rr'
  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end
