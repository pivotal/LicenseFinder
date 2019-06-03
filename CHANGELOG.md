# [5.8.0] / 2019-05-22

### Added
* Trash Package Manager - [3a3d854](https://github.com/pivotal/LicenseFinder/commit/3a3d8541c4ea64607df6b120111aff324f93778d) 

### Fixed
* Prefer to use `origin` over `path` for govendor - [31c6041](https://github.com/pivotal/LicenseFinder/commit/31c6041926a27b61c35c05c6433a87d0af78c1e5) 

# [5.7.1] / 2019-03-08

# [5.7.0] / 2019-03-01

### Added
* Ruby 2.6.1 support - [8d60ed1](https://github.com/pivotal/LicenseFinder/commit/8d60ed13f99b830cc1352900f90e2b298105f518) 

### Changed
* Conan version is locked to 1.11.2 to avoid breaking changes - [72b766a](https://github.com/pivotal/LicenseFinder/commit/72b766a948be5b0f8eade75e716796f50ea9ebf3) 

# [5.6.2] / 2019-01-28

# [5.6.1] / 2019-01-25

### Changed
* Updated GOLANG to 1.11.4 in Docker image [#163424880] - [67e5e1f](https://github.com/pivotal/LicenseFinder/commit/67e5e1ffef19acf3a63cac55c5aa3626fb4c7491)

# [5.6.0] / 2018-12-19

### Added
* Add support for JSON reports [#161595251] - [5a1f735](https://github.com/pivotal/LicenseFinder/commit/5a1f73515c83cbf8ce17275c4c9d1af43d0db772) 
* Removed the removal of nested projects - [6e1941c](https://github.com/pivotal/LicenseFinder/commit/6e1941c4d06676988ff8bdad81bd83a4bb5c17e9) 
* Show verbose errors from prepare commands [#161462746] - [2b14299](https://github.com/pivotal/LicenseFinder/commit/2b142995d06572f772104c39437d0b64f9569f79) 

* Support to find gradle.kts files [#161629958] - [f7cb587](https://github.com/pivotal/LicenseFinder/commit/f7cb587787f4de282c34afe66c0a2d0c1c72a84f) 

### Fixed
* Go modules reports incorrect install paths - [9ab5aa9](https://github.com/pivotal/LicenseFinder/commit/9ab5aa9aadc9432c5359ed2af2cb32e28fac277a) 
Revert "* Go modules reports incorrect install paths" - [fcead98](https://github.com/pivotal/LicenseFinder/commit/fcead980ae2cc24f7193a1f38944f4df60a8c3fc) 

* Fix install_paths for go mod now accurately report dependency installation directories  [#161943322 finish] - [ea28c06](https://github.com/pivotal/LicenseFinder/commit/ea28c06898964043f5849b64b4043bde81a2d7cd) 
* Handle log file names created with whitespaces and slashes - [7d6f9da](https://github.com/pivotal/LicenseFinder/commit/7d6f9da5006e1e7bbb71f594188ab87ee76ddfbb) 

### Changed
* Updated go-lang to 1.11.2 in the Docker - [d720f9c](https://github.com/pivotal/LicenseFinder/commit/d720f9c16f82044b5024213bec41b8e9f34cf306) 

# [5.5.2] / 2018-10-17

### Fixed
* go mod prepare command being incorrect - [480c465](https://github.com/pivotal/LicenseFinder/commit/480c4654cde7342456318ed4e28b6cebd4a09e4b) 

# [5.5.1] / 2018-10-16

### Added
* Documentation for asterisks being added to license names [#158960018] - [154b727](https://github.com/pivotal/LicenseFinder/commit/154b7273b1c18e64afa48799b50588251f99e982) 
* Document the prepare option on the command line - [c283a38](https://github.com/pivotal/LicenseFinder/commit/c283a38d9e8b9feefc5afe32f1df55b357a33333) 

### Fixed
* Go modules are forced to be enabled on go mod package managers - [cf9123d](https://github.com/pivotal/LicenseFinder/commit/cf9123d654b98cdef872d3b21631e69960abe365) 

# [5.5.0] / 2018-10-11

### Added
* Go Module support - [8a20210](https://github.com/pivotal/LicenseFinder/commit/8a202109e942316434978befd33854aa985dd872)

### Changed
* Lowering gemspec ruby requirement to support jruby 9.1.x - [279bd25](https://github.com/pivotal/LicenseFinder/commit/279bd25bbebbd3851dcc0062c3c47f7c7063dad8)
* Bumps rubocop to 0.59.2 - [291d335](https://github.com/pivotal/LicenseFinder/commit/291d3358921dbb47bc612b77656353da07e71a2b)

### Fixed
* 'dlf' with no-args should get a login shell - [2b019fb](https://github.com/pivotal/LicenseFinder/commit/2b019fb1126ec2fcb9cafa092cad6d27b875e5f9) - Kim Dykeman
* Do not include godep dependencies with common paths - [23e951f](https://github.com/pivotal/LicenseFinder/commit/23e951fae56a43abde52ecefa73e8a5ff73bb688) 
* Remove uneeded bundle install in dlf [#160758436] - [f44c73f](https://github.com/pivotal/LicenseFinder/commit/f44c73f6c06838a29ff9a75932e08fb1445557ca) 

* dlf gemfile directory issues [#160758436 finish] - [2db3972](https://github.com/pivotal/LicenseFinder/commit/2db397261654bca89771e85984b4ae6819274e55) 
Revert "* dlf gemfile directory issues [#160758436 finish]" - [6b17ddc](https://github.com/pivotal/LicenseFinder/commit/6b17ddc4202518ffd167c8d38a2045a36eb00144) 

# [5.4.1] / 2018-09-18

### Fixed
* Extra dependencies showing up for some go projects [#160438065] - [dfb1367](https://github.com/pivotal/LicenseFinder/commit/dfb136724721843c1196e74a6b4c762538af62ba) 
* remove workspace-aggregator as a yarn dependency [#159612717 finish] - [4e0afd0](https://github.com/pivotal/LicenseFinder/commit/4e0afd0ba79623f5bb4c055d42a76ba77ce1c785) 

# [5.4.0] / 2018-08-20

### Added
* NuGet + mono installation to Dockerfile
* Add An all caps version of the 'LICENCE' spelling as a candidate file

### Changed
* Upgrades Dockerfile base to Xenial

# [5.3.0] / 2018-06-05

### Added
* Experimental support for Rust dependencies with Cargo - [2ef3129](https://github.com/pivotal/LicenseFinder/commit/2ef31290f7abf51db5b7173302d1e535508bbd7a)
* Add project roots command to list paths to scan - [b7a22ea](https://github.com/pivotal/LicenseFinder/commit/b7a22eacfac0e1b9334998de606df69ec3156f77)

### Removed
* Remove HTTParty dependency - [c52d014](https://github.com/pivotal/LicenseFinder/commit/c52d014df1ca9cd3838d03c60daa6fad954c5579) 

# [5.2.3] / 2018-05-14

# [5.2.1] / 2018-05-14

### Changed
* Updated go-lang to 1.10.2 in the Docker * Updated Maven to 3.5.3 in the Docker - [1decf6a](https://github.com/pivotal/LicenseFinder/commit/1decf6ad27c9edf96b4f5cccd9a7ca0955fed9f2) - Mark Fioravanti

# [5.2.0] / 2018-05-09

### Fixed
* Support for pip 10.0.1 - [286f679](https://github.com/pivotal/LicenseFinder/commit/286f6790dc71c97c0e93ecdfe0c6fddad75165cc)

# [5.1.1] / 2018-05-08

### Added
* CC License detection

### Fixed
* Yarn package manager now handles non-ASCII characters
* in_umbrella: true dependencies for Mix
* Pivotal Repo Renamed to pivotal

# [5.1.0] / 2018-04-02

### Added
* Support for Ruby 2.5.1 - [9c82a84](https://github.com/pivotal/LicenseFinder/commit/9c82a84a3cff0765a45fa28dc2b05ab32880fb00) 
* Support for Scala build Tool (sbt ) - [2115ddf](https://github.com/pivotal/LicenseFinder/commit/2115ddfe9481d17e6b1d0ac63d6ae1c6143f370c) - Bradford D. Boyle
* Condense gvt paths with identical shas into their common path - [9e1071d](https://github.com/pivotal/LicenseFinder/commit/9e1071d3c92405a8605727ad1164d6581dc50533)

### Fixed
* Added back the pip prepare commands [#156376451 finish] - [fdd63fb](https://github.com/pivotal/LicenseFinder/commit/fdd63fb38332230e0cce0ee1b47aa5ccd0eebc36) 
* Govendor not consolidating common paths from the same SHA - [bdd23c9](https://github.com/pivotal/LicenseFinder/commit/bdd23c94ae6ff09a2466c8875e554de60db6603c) 

### Deprecated
* Support for Ruby 2.1 
* Support for Ruby 2.2 
* Support for jruby - [9c82a84](https://github.com/pivotal/LicenseFinder/commit/9c82a84a3cff0765a45fa28dc2b05ab32880fb00) 

# [5.0.3] / 2018-02-13

### Changed
* Add the -vendor-only flag to dep-ensure calls - [e305bd1](https://github.com/pivotal/LicenseFinder/commit/e305bd1d5b2d9653f828c3940b59a12903904699) 
* Update detected paths for Nuget - [3fe8995](https://github.com/pivotal/LicenseFinder/commit/3fe89955d82c3467628abbd2ca9ba159bfeb7df6)

# [5.0.2] / 2018-02-06

### Fixed
* Add conditional production flag to npm - [533f9b8](https://github.com/pivotal/LicenseFinder/commit/533f9b8fda250655f3613444da49fdce60215237) 
* conan install & info commands - [322e64c](https://github.com/pivotal/LicenseFinder/commit/322e64c402f4e45d97c6f3bf67c3ffdaabbb359f) 
* Duplicate approvals in decisions file - [a8e6141](https://github.com/pivotal/LicenseFinder/commit/a8e6141cd7ac7ed2aa10b35c55954a48bacf3523) 
* log path issues - [9f1bae1](https://github.com/pivotal/LicenseFinder/commit/9f1bae12c88771229e0a919876f4de6bcad31677) 

* Fix yarn not working with --project_path option - [c6ed08d](https://github.com/pivotal/LicenseFinder/commit/c6ed08dd8342dec9fcc3e6377f88d5ef01600928) 

# [5.0.0] / 2018-01-15

### Added
* NPM prepare - [e7a0d30](https://github.com/pivotal/LicenseFinder/commit/e7a0d30cb77e5503b5a934b26dbd3dc272dc5605) 
* Specify log directory for prepare - [b9a5991](https://github.com/pivotal/LicenseFinder/commit/b9a599171f3fda2affa9381d998e2158a2bf7fac) 

* Added prepare step for elixir projects - [38b08ea](https://github.com/pivotal/LicenseFinder/commit/38b08eae23b6b0c2bbaa3aea7845ab6a8d9b028b) 

### Fixed
* Action_items resolves decisions file path - [c2a92ab](https://github.com/pivotal/LicenseFinder/commit/c2a92ab62203efb890dfeb1798d377c8d835feb6) 

* Bower prepare step - [bb11d7f](https://github.com/pivotal/LicenseFinder/commit/bb11d7f07cc5e436381f01245a46033af6bb2d3b) 

### Changed
* Package Manager will now log if prepare step fails. Instead of erroring out - [54da71e](https://github.com/pivotal/LicenseFinder/commit/54da71e98f14cd199c39dfd7b762030fcac60ccb) 

# [4.0.2] / 2017-11-16

### Fixed

* Fixed --quiet not being available on the report task
* Fixed --recursive not being available on the action_items task

# [4.0.1] / 2017-11-14

### Fixed

* Add missing toml dependency to gemspec

# [4.0.0] / 2017-11-10

### Changed

* CLI output has been altered to be clear about active states and installed states.
* option `--subprojects`have been renamed to `--aggregate_paths` in order to be clear about its functionality

### Fixed

* Fixed issue where dangling symbolic link would cause License Finder to crash and not continue. Instead, License Finder will now warn about the issue and continue.

# [3.1.0] / 2017-11-10

### Added

* Added support for [Carthage](https://github.com/Carthage/Carthage) 
* Added support for [gvt](https://github.com/FiloSottile/gvt)
* Added support for [yarn](https://yarnpkg.com/en/)
* Added support for [glide](https://github.com/Masterminds/glide)
* Added support for [GoVendor](https://github.com/kardianos/govendor)
* Added support for [Dep](https://github.com/golang/dep)
* Added support for [Conan](https://conan.io/)
* Added `--prepare` option
  * `--prepare`/`-p` is an option which can now be passed to the `action_items` or `report` task of `license_finder`
  * `prepare` will indicate to License Finder that it should attempt to prepare the project before running in a License scan.

### Changed

* Upgrade `Gradle` in Dockerfile
* Clean up some CLI interaction and documentation

### Fixed

* `build-essential` was added back into the Dockerfile after accidentally being removed
* Ignore leading prefixes such as 'The' when looking for licenses

# [3.0.4] / 2017-09-14

### Added
* Added concourse pipeline file for Docker image process (#335, #337)
* Add status checks to pull requests
* Allow Custom Pip Requirements File Path (#328, thanks @sam-10e)

### Fixed
* Fixed NPM stack too deep issue (#327, #329)

# [3.0.3] / Skipped because of accidentally yanking gem

# [3.0.2] / 2017-07-27:

### Added

* Add CI status checks to pull requests (#321)

### Fixed

* Support NPM packages providing a string for the licenses key (#317)
* Use different env-var to indicate ruby version for tests (#303)
* Resolve NPM circular dependencies (#306, #307, #311, #313, #314, #319, #322)

# [3.0.1] / 2017-07-12:

### Added

* Add --maven-options to allow options for maven scans (#305, thanks @jgielstra!)

### Fixed:

* Restore the original GOPATH after modifying it (#287, thanks @sschuberth!)
* LF doesn't recognize .NET projects using 'packages' directory (#290, #292, thanks @bspeck!)
* Use glob for finding acknowledgements path for CocoaPods (#177, #288, thanks @aditya87!)
* Fix some failing tests on Windows (#294, thanks @sschuberth!)
* Add warning message if no dependencies are recognized (#293, thanks @bspeck!)
* Switch to YAJL for parsing the json output from npm using a tmp file rather than an in-memory string (#301, #304)
* Fix dockerfile by explicitly using rvm stable (#303)
* Report multiple versions of the same NPM dependency (#310)

# [3.0.0] / 2016-03-02

### Added

* Changed dependencies to be unique based on name _and_ version (#241)
* Enable '--columns' option with text reports (#244, thanks @raimon49!)
* Flag maven-include-groups adds group to maven depenency information (#219, #258, thanks @dgodd!)
* Package managers determine their package management command (#250, Thanks @sschuberth!)
* Support --ignored_groups for maven
* Support `homepage` column for godeps dependencies, and dependencies from go workspaces using `.envrc`
* Support `license_links` column for csv option (#281, Thanks @lbalceda!)
* Added a Dockerfile for [licensefinder/license_finder](https://hub.docker.com/r/licensefinder/license_finder/)
* Switched from Travis to Concourse

### Fixed

* Gradle works in CI containers where TERM is not set (revert and fix of c15bdb7, which broke older versions of gradle)
* Check for the correct Ruby Bundler command: `bundle` (#233. Thanks, @raimon49!)
* Uses settings.gradle to determine the build file name (#248)
* Fix detecting the Gradle wrapper if not scanning the current directory (#238, Thanks @sschuberth!)
* Use maven wrapper if available on maven projects
* Check golang package lists against standard packages instead of excluding short package paths (#243)
* Update the project_sha method to return the sha of the dependency, not the parent project
* Change Maven wrapper to call mvn.cmd and fall back on mvn.bat (#263, Thanks @sschuberth!)
* Allow bower to run as root
* Fix packaging errors scanning pip based projects
* Add JSON lib attribute to handle deeply nested JSON (#269. Thanks, @antongurov!)
* Use the fully qualified name of the license-maven-plugin (#284)

# 2.1.2 / 2016-06-10

Bugfixes:

* NuGet limits its recursive search for .nupkg packages to the `vendor` subdirectory. (#228)


# 2.1.1 / 2016-06-09

Features:

* GoWorkspace now detects some non-standard package names with only two path parts. (#226)

Bugfixes:

* NuGet now appropriately returns a Pathname from #package_path (previously was a String) (#227)
* NuGet now correctly chooses a directory with vendored .nupkg packages


# 2.1.0 / 2016-04-01

* Features
  * support a `groups` in reports (#210) (Thanks, Jon Wolski!)
  * GoVendor and GoWorkspace define a package management tool, so they won't try to run if you don't have `go` installed
  * PackageManagers are not activated if the underlying package management tool isn't installed
  * detect GO15VENDOREXPERIMENT as evidence of a go workspace project
  * provide path-to-dependency in recursive mode (#193)
  * dedup godep dependencies (#196)
  * add support for MPL2 detection
  * detect .envrc in a parent folder (go workspaces) (#199)
  * miscellaneous nuget support improvements (#200, #201, #202)
  * miscellaneous go support improvements (#203, #204)
  * add support for Golang 1.5 vendoring convention (#207)
  * return the package manager that detected the dependency (#206)
  * Add support for including maven/gradle GroupIds with `--gradle-include-groups`
  * Godep dependencies can display the full commit SHA with `--go-full-version`
  * specific versions of a dependency can be approved (#183, #185). (Thanks, @ipsi!)
  * improved "go workspace" support by looking at git submodules. (Thanks, @jvshahid and @aminjam!)
  * added an "install path" field to the report output. (Thanks, @jvshahid and @aminjam!)
  * Licenses can be blacklisted.  Dependencies which only have licenses in the blacklist will not be approved, even if someone tries.
  * Initial support for the Nuget package manager for .NET projects
  * Experimental support for `godep` projects
  * Experimental support for "golang workspace" projects (with .envrc)
  * Improved support for multi-module `gradle` projects
  * Gradle 2.x support (experimental)
  * Experimental support for "composite" projects (multiple git submodules)
  * Experimental support for "license diffs" between directories

* Bugfixes
  * `rubyzip` is now correctly a runtime dependency
  * deep npm dependency trees no longer result in some packages having no metadata (#211)
  * columns fixed in "recursive mode" (#191)
  * gradle's use of termcaps avoided (#194)


# 2.0.4 / 2015-04-16

* Features

  * Allow project path to be set in a command line option (Thanks, @robertclancy!)


# 2.0.3 / 2015-03-18

* Bugfixes

  * Ignoring subdirectories of a LICENSE directory. (#143) (Thanks, @pmeskers and @yuki24!)


# 2.0.2 / 2015-03-14

* Features

  * Show requires/required-by relationships for pip projects
  * Expose homepage in CSV reports
  * Support GPLv3

* Bugfixes

  * license_finder works with Python 3; #140
  * For pip projects, limit output to the distributions mentioned in
    requirements.txt, or their dependencies, instead of all installed
    distributions, which may include distributions from other projects. #119


# 2.0.1 / 2015-03-02

* Features

  * Support for rebar projects


# 2.0.0 / 2015-03-02

* Features

  * Stores every decision that has been made about a project's dependencies,
    even if a decision was later reverted.  These decisions are kept in an
    append-only YAML file which can be considered an audit log.
  * Stores timestamps and other optional transactional metadata (who, why)
    about every kind of decision.
  * When needed, applies those decisions to the list of packages currently
    reported by the package managers.
  * Removed dependencies on sqlite and sequel.
  * The CLI never writes HTML or CSV reports to the file system, only to
    STDOUT. So, users have more choice over which reports to generate, when to
    generate them, and where to put them. See `license_finder report`.  If you
    would like to update reports automatically (e.g., in a rake task or git
    hook) see this gist: https://gist.github.com/mainej/1a4d61a92234c5cebeab.
  * The configuration YAML file is no longer required, though it can still be
    useful.  Most of its functionality has been moved into the decisions
    infrastructure, and the remaining bits can be passed as arguments to the
    CLI.  Most users will not need these arguments.  If the file is present, the
    CLI arguments can be omitted.  The CLI no longer updates this file.
  * Requires pip >= 6.0

* Bugfixes

  * `license_finder` does not write anything to the file system, #94, #114, #117


# 1.2.1 / unreleased

* Features

  * Can list dependencies that were added manually


# 1.2 / 2014-11-10

* Features

  * Adding support for CocoaPods >= 0.34. (#118)
  * For dependencies with multiple licenses, the name of each license is
    listed, and if any are whitelisted, the dependency is whitelisted
  * Added `--debug` option when scanning, to provide details on
    packages, dependencies and where each license was discovered.


# 1.1.1 / 2014-07-29

* Bugfixes

  * Process incorrectly-defined dependencies.
    [Original issue.](https://github.com/pivotal/LicenseFinder/issues/108)
  * Allow license_finder to process incorrectly-defined dependencies.


# 1.0.1 / 2014-05-28

* Features

  * For dependencies with multiple licenses, the dependency is listed as
    'multiple licenses' along with the names of each license
  * Added 'ignore_dependencies' config option to allow specific
    dependencies to be excluded from reports.

* Bugfixes

  * Dependency reports generate when license_finder.yml updates
  * Dependency reports generate when config is changed through the command line


# 1.0.0.1 / 2014-05-23

* Bugfixes

  * LicenseFinder detects its own license


# 1.0.0 / 2014-04-03

* Features

  * When approving a license, can specify who is approving, and why.
  * Remove `rake license_finder` task from Rails projects.  Just include
    'license_finder' as a development dependency, and run `license_finder` in
    the shell.


# 0.9.5.1 / 2014-01-30

* Features

  * Adds homepage for Bower, NPM, and PIP packages


# 0.9.5 / 2014-01-30

* Features

  * Add more aliases for known licenses
  * Drop support for ruby 1.9.2
  * Large refactoring to simply things, and make it easier to add new package managers

* Bugfixes

  * Make node dependency json parsing more robust
  * Clean up directories created during test runs


# 0.9.4 / 2014-01-05

* Features

  * Add detailed csv report
  * Add markdown report
  * Add support for "licenses" => ["license"] (npn)
  * Add basic bower support
  * Allow adding/removing multiple licenses from whitelist

* Bugfixes

  * Use all dependencies by default for npm as bundler does


# 0.9.3 / 2013-10-01

* Features

  * New Apache 2.0 license alias

* Bugfixes

  * Fix problem which prevented license finder from running in rails < 3.2


# 0.9.2 / 2013-08-17

* Features

  * Support for python and node.js projects

* Bugfixes

  * Fix HTML output in firefox


# 0.9.1 / 2013-07-30

* Features

  * Projects now have a title which can be configured from CLI
  * JRuby officially supported. Test suite works against jruby, removed 
    warnings
  * Internal clean-up of database behavior
  * Updated documentation with breakdown of HTML report

* Bugfixes

  * dependencies.db is no longer modified after license_finder runs and finds
    no changes
  * Fix more CLI grammar/syntax errors
  * HTML report now works when served over https (PR #36 - bwalding)
  * dependencies.txt is now dependencies.csv (It was always a csv in spirit)


# 0.9.0 / 2013-07-16

* Features

  * Clarify CLI options and commands in help output
  * Can manage whitelisted licenses from command line
  * Improved New BSD license detection

* Bugfixes

  * Fix CLI grammar errors
  * Using license_finder in a non-RVM environment now works (Issue #35)


# 0.8.2 / 2013-07-09

* Features

  * Switch to thor for CLI, to support future additions to CLI
  * Restore ability to manage (add/remove) dependencies that Bundler can't find
  * Can maintain ignored bundler groups from command line

* Bugfixes

  * Fix bug preventing manual approval of child dependencies (Issue #23)
  * Fix issue with database URI when the absolute path to the database file
    contains spaces.
  * Upgrading from 0.7.2 no longer removes non-gem dependencies (Issue #20)


# 0.8.1 / 2013-04-14

* Features

  * JRuby version of the gem.
  * Official ruby 2.0 support.
  * CLI interface for moving dependencies.* files to `doc/`.

* Bugfixes

  * Fix ruby 1.9.2 support.


# 0.8.0 / 2013-04-03

* Features

  * Add spinner to show that the binary is actually doing something.
  * Add action items to dependencies.html.
  * Add generation timestamp to dependencies.html.
  * Default location for dependencies.* files is now `doc/`.
  * Temporarily remove non-bundler (e.g. JavaScript) dependencies. This will
    be readded in a more sustainable way soon.
  * Use sqlite, not YAML, for dependencies.
  * Officially deprecate rake tasks.

* Bugfixes

  * Don't blow away manually set licenses when dependencies are rescanned.
  * Ignore empty `readme_files` section in dependencies.yml.
  * Clean up HTML generation for dependencies.html.
  * Add an option to silence the binary's spinner so as not to fill up log
    files.


# 0.7.2 / 2013-02-18

* Features

  * Dependency cleanup.


# 0.7.1 / 2013-02-18

* Features

  * Add variants to detectable licenses.
  * Remove README files from data persistence.


# 0.7.0 / 2012-09-25

* Features

  * Dependencies can be approved via CLI.
  * Dependencies licenses can be set via CLI.


# 0.6.0 / 2012-09-15

* Features

  * Create a dependencies.html containing a nicely formatted version of
    dependencies.txt, with lots of extra information.
  * All rake tasks, and the binary, run the init task automatically.
  * Simplify dependencies.txt file since more detail can now go into
    dependencies.html.
  * Promote binary to be the default, take first steps to deprecate rake task.

* Bugfixes

  * Fix formatting of `rake license:action_items` output.


# 0.5.0 / 2012-09-12

* Features

  * `rake license:action_items` exits with a non-zero status if there are
    non-approved dependencies.
  * New binary, eventual replacement for rake tasks.
  * Initial implementation of non-gem dependencies.
  * Support BSD, New BSD, and Simplified BSD licenses.
  * Improve ruby license detection.
  * Add dependency's bundler group to dependencies.txt output.
  * Add description and summary to dependencies.txt output.

* Bugfixes

  * Create `config/` director if it doesn't exist, don't blow up.
  * Better support for non-US word spellings.


# 0.4.5 / 2012-09-09

* Features

  * Allow dependencies.* files to be written to a custom directory.
  * Detect LGPL licenses
  * Detect ISC licenses

* Bugfixes

  * Fix blow up if there's not `ignore_groups` setting in the config file.


[Unreleased]: https://github.com/pivotal/LicenseFinder/compare/v4.0.2...HEAD
[4.0.2]: https://github.com/pivotal/LicenseFinder/compare/v4.0.1...v4.0.2
[4.0.1]: https://github.com/pivotal/LicenseFinder/compare/v4.0.0...v4.0.1
[4.0.0]: https://github.com/pivotal/LicenseFinder/compare/v3.1.0...v4.0.0
[3.1.0]: https://github.com/pivotal/LicenseFinder/compare/v3.0.4...v3.1.0
[3.0.4]: https://github.com/pivotal/LicenseFinder/compare/v3.0.2...v3.0.4
[3.0.2]: https://github.com/pivotal/LicenseFinder/compare/v3.0.1...v3.0.2
[3.0.1]: https://github.com/pivotal/LicenseFinder/compare/v3.0.0...v3.0.1
[3.0.0]: https://github.com/pivotal/LicenseFinder/compare/v2.1.2...v3.0.0
[5.0.0]: https://github.com/pivotal/LicenseFinder/compare/v4.0.2...v5.0.0
[5.0.2]: https://github.com/pivotal/LicenseFinder/compare/v5.0.0...v5.0.2
[5.0.3]: https://github.com/pivotal/LicenseFinder/compare/v5.0.2...v5.0.3
[5.1.0]: https://github.com/pivotal/LicenseFinder/compare/v5.0.3...v5.1.0
[5.1.1]: https://github.com/pivotal/LicenseFinder/compare/v5.1.0...v5.1.1
[5.1.1]: https://github.com/pivotal/LicenseFinder/compare/v5.1.0...v5.1.1
[5.2.0]: https://github.com/pivotal/LicenseFinder/compare/v5.1.1...v5.2.0
[5.2.1]: https://github.com/pivotal/LicenseFinder/compare/v5.2.0...v5.2.1
[5.2.3]: https://github.com/pivotal/LicenseFinder/compare/v5.2.1...v5.2.3
[5.3.0]: https://github.com/pivotal/LicenseFinder/compare/v5.2.3...v5.3.0
[5.4.0]: https://github.com/pivotal/LicenseFinder/compare/v5.3.0...v5.4.0
[5.4.1]: https://github.com/pivotal/LicenseFinder/compare/v5.4.0...v5.4.1
[5.5.0]: https://github.com/pivotal/LicenseFinder/compare/v5.4.1...v5.5.0
[5.5.1]: https://github.com/pivotal/LicenseFinder/compare/v5.5.0...v5.5.1
[5.5.2]: https://github.com/pivotal/LicenseFinder/compare/v5.5.1...v5.5.2
[5.6.0]: https://github.com/pivotal/LicenseFinder/compare/v5.5.2...v5.6.0
[5.6.1]: https://github.com/pivotal/LicenseFinder/compare/v5.6.0...v5.6.1
[5.6.2]: https://github.com/pivotal/LicenseFinder/compare/v5.6.1...v5.6.2
[5.7.0]: https://github.com/pivotal/LicenseFinder/compare/v5.6.2...v5.7.0
[5.7.1]: https://github.com/pivotal/LicenseFinder/compare/v5.7.0...v5.7.1
[5.8.0]: https://github.com/pivotal/LicenseFinder/compare/v5.7.1...v5.8.0
