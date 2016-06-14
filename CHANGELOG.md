# 2.1.3 / 2016-06-14

* Features

  * Support for composer projects


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
