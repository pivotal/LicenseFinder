# License Finder

[![Code Climate](https://codeclimate.com/github/pivotal/LicenseFinder.png)](https://codeclimate.com/github/pivotal/LicenseFinder)

Build status
* Ruby 2.3.8 [![Ruby 2.3.8 build status](https://norsk.cf-app.com/api/v1/teams/main/pipelines/LicenseFinder/jobs/ruby-2.3.8/badge)](https://norsk.cf-app.com/teams/main/pipelines/LicenseFinder)
* Ruby 2.4.9 [![Ruby 2.4.9 build status](https://norsk.cf-app.com/api/v1/teams/main/pipelines/LicenseFinder/jobs/ruby-2.4.9/badge)](https://norsk.cf-app.com/teams/main/pipelines/LicenseFinder)
* Ruby 2.5.7 [![Ruby 2.5.7 build status](https://norsk.cf-app.com/api/v1/teams/main/pipelines/LicenseFinder/jobs/ruby-2.5.7/badge)](https://norsk.cf-app.com/teams/main/pipelines/LicenseFinder)
* Ruby 2.6.5 [![Ruby 2.6.5 build status](https://norsk.cf-app.com/api/v1/teams/main/pipelines/LicenseFinder/jobs/ruby-2.6.5/badge)](https://norsk.cf-app.com/teams/main/pipelines/LicenseFinder)
* Ruby 2.7.1 [![Ruby 2.7.1 build status](https://norsk.cf-app.com/api/v1/teams/main/pipelines/LicenseFinder/jobs/ruby-2.7.1/badge)](https://norsk.cf-app.com/teams/main/pipelines/LicenseFinder)
* JRuby 9.2.9.0 [![JRuby 9.2.9.0 build status](https://norsk.cf-app.com/api/v1/teams/main/pipelines/LicenseFinder/jobs/ruby-jruby-9.2.9.0/badge)](https://norsk.cf-app.com/teams/main/pipelines/LicenseFinder)


LicenseFinder works with your package managers to find dependencies,
detect the licenses of the packages in them, compare those licenses
against a user-defined list of permitted licenses,
and give you an actionable exception report.

* code: https://github.com/pivotal/LicenseFinder
* ci: https://norsk.cf-app.com/teams/main/pipelines/LicenseFinder
* docker: [licensefinder/license_finder](https://hub.docker.com/r/licensefinder/license_finder/)
  * the docker image contains all the package managers needed to run `license_finder`
* support:
  * license-finder@googlegroups.com
  * https://groups.google.com/forum/#!forum/license-finder
* backlog: https://www.pivotaltracker.com/n/projects/234851

### Supported project types

| Project Type | Package Manager | Tested on Version |
| ------------ | --------------- | -------:|
| Ruby Gems    | bundler         | 1.16.6  |
| Python 2.7 Eggs  | pip2             | 19.0.2  |
| Python 3.5 Eggs  | pip3             | 19.0.2  |
| Node.js      | npm             | 6.4.1   |
| Bower        | bower           | 1.8.4   |
| Nuget (without license discovery) | nuget | 4.7.1.5393 |
| Godep        | Godep           | 80      |
| Go workspace (via a `.envrc` file) | Go lang | 1.11.5 |
| Go modules   | Go lang         | 1.11.5  |
| Java         | maven           | 3.6.0   |
| Java         | gradle          | 4.10.3  |

### Experimental project types

* Erlang (via `rebar` and `Erlang.mk`)
* Objective-C, Swift (via Carthage, CocoaPods \[0.39 and below. See [CocoaPods Specs Repo Sharding](http://blog.cocoapods.org/Sharding/)\]) and Swift Package Manager)
* Objective-C (+ CocoaPods 0.39 and below. See [CocoaPods Specs Repo Sharding](http://blog.cocoapods.org/Sharding/))
* Elixir (via `mix`)
* Golang (via `gvt`, `glide`,`dep`, `trash` and `govendor`)
* JavaScript (via `yarn`)
* C++/C (via `conan`)
* Scala (via `sbt`)
* Rust (via `cargo`)
* Go Modules (via `go mod`)
* PHP (via `composer`)
* Python (via Conda [Conda 4.8.3, Python 3.7, Bash; requires an `environment.yml` or `environment.yaml`])

## Installation

License Finder requires Ruby 2.3.3 or greater to run. If you have an older
version of Ruby installed, you can update via Homebrew:

```sh
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

then:

```sh
$ brew install ruby
```

The easiest way to use `license_finder` is to install it as a command
line tool, like brew, awk, gem or bundler:

```sh
$ gem install license_finder
```

Though it's less preferable, if you are using bundler in a Ruby
project, you can add `license_finder` to your Gemfile:

```ruby
gem 'license_finder', :group => :development
```

This approach helps you remember to install `license_finder`, but can
pull in unwanted dependencies, including `bundler`. To mitigate this
problem, see [Excluding Dependencies](#excluding-dependencies).


## Usage

Make sure your dependencies are installed (with your package manager's install command: `bundle install`, `npm install`, etc.)

The first time you run `license_finder` it will list all your project's packages.

```sh
$ license_finder
```

Or, if you installed with bundler:

```sh
$ bundle exec license_finder
```

The output will report that none of your packages have been
approved.  Over time you will tell `license_finder` which packages
are approved, so when you run this command in the future, it will
report current action items; i.e., packages that are new or have
never been approved.

If you don't wish to see progressive output "dots", use the `--quiet`
option.

If you'd like to see debugging output, use the `--debug`
option. `license_finder` will then output info about packages, their
dependencies, and where and how each license was discovered. This can
be useful when you need to track down an unexpected package or
license.

If you do not want to manually run an individual package manager's prepare
command (ex: `bundle install`, `npm install`, etc) to ensure your project
is fully prepared to be scanned, use the `--prepare` or `-p` option which will run
each active package manager's prepare command for you. If you would like to continue
running `license_finder` even if there is an issue with a prepare step, use the
`--prepare-no-fail` option which prepares but carries on despite any potential failures.

Run `license_finder help` to see other available commands, and
`license_finder help [COMMAND]` for detailed help on a specific
command.

### Docker

If you have docker installed, try using the included `dlf` script (potentially
symlinked to be in your path via `ln -s LicenseFinder/dlf /usr/local/bin` or
whatever method you prefer). This will run any commands passed to it inside a
pre-provisioned Docker container to maintain consistent versions of all the
package managers. For example,

```
$ dlf npm --version
5.3.0

$ dlf license_finder --help

Dependencies that need approval:
...
license_finder, 3.0.3, MIT

$ dlf "bundle install && license_finder"
```

You can better understand the way this script works by looking at its source, but for
reference it will mount your current directory at the path `/scan` and run any commands
passed to it from that directory.

Note that the docker image will run the gem which is installed within it.
So the docker image tagged `4.0.2` will run *License Finder Version 4.0.2*

See the [contributing guide](https://github.com/pivotal/LicenseFinder/blob/master/CONTRIBUTING.md) for information on development. 

### Activation

`license_finder` will find and include packages for all supported
languages, as long as that language has a package definition in the project directory:

* `Gemfile` (for `bundler`)
* `requirements.txt` (for `pip`)
* `package.json` (for `npm`)
* `pom.xml` (for `maven`)
* `build.gradle` (for `gradle`)
* `settings.gradle` that specifies `rootProject.buildFileName` (for `gradle`)
* `bower.json` (for `bower`)
* `Podfile` (for `pod`)
* `Cartfile` (for `carthage`)
* `workspace-state.json` under build directory (provided as enviroment variable `SPM_DERIVED_DATA` for Xcode, or default `.build` for non-Xcode projects), (for `spm`)
* `rebar.config` (for `rebar`)
* `Erlang.mk` or `erlang.mk` file (for `Erlang.mk`)
* `mix.exs` (for `mix`)
* `packages/` directory (for `nuget`)
* `*.csproj` (for `dotnet`)
* `vendor/manifest` or `*/vendor/manifest` file (for `gvt`)
* `glide.lock` file (for `glide`)
* `vendor/vendor.json` file (for `govendor`)
* `Gopkg.lock` file (for `dep`)
* `go.mod` file (for `go mod`)
* `vendor.conf` file (for `trash`)
* `yarn.lock` file (for `yarn`)
* `conanfile.txt` file (for `conan`)
* `build.sbt` file (for `sbt`)
* `Cargo.lock` file (for `cargo`)
* `composer.lock` file (for `composer`)


### Continuous Integration

`license_finder` will return a non-zero exit status if there are unapproved
dependencies. This can be useful for inclusion in a CI environment to alert you
if someone adds an unapproved dependency to the project.


## Approving Dependencies

`license_finder` will inform you whenever you have an unapproved dependency.
If your business decides this is an acceptable risk, the easiest way to approve
the dependency is by running `license_finder approvals add`.

For example, let's assume you've added the `awesome_gpl_gem`
to your Gemfile, which `license_finder` reports is unapproved:

```sh
$ license_finder
Dependencies that need approval:
awesome_gpl_gem, 1.0.0, GPL
```

Your business tells you that in this case, it's acceptable to use this
gem. You now run:

```sh
$ license_finder approvals add awesome_gpl_gem
```

If you rerun `license_finder`, you should no longer see
`awesome_gpl_gem` in the output.

To approve specific version

```sh
$ license_finder approvals add awesome_gpl_gem --version=1.0.0
```

To record who approved the dependency and why:

```sh
$ license_finder approvals add awesome_gpl_gem --who CTO --why "Go ahead"
```

### Permitting Licenses

Approving packages one-by-one can be tedious.  Usually your business has
blanket policies about which packages are approved.  To tell `license_finder`
that any package with the MIT license should be approved, run:

``` sh
$ license_finder permitted_licenses add MIT
```

Any current or future packages with the MIT license will be excluded from the
output of `license_finder`.

You can also record `--who` and `--why` when changing permitted licenses,
or making any other decision about your project.


## Output and Artifacts

### Decisions file

Any decisions you make about approvals will be recorded in a YAML file named
`doc/dependency_decisions.yml`.

This file must be committed to version control.  Rarely, you will have to
manually resolve conflicts in it.  In this situation, keep in mind that each
decision has an associated timestamp, and the decisions are processed
top-to-bottom, with later decisions overwriting or appending to earlier
decisions.

### Output from `action_items`

You could expect `license_finder`, which is an alias for `license_finder
action_items` to output something like the following on a Rails project where
MIT had been permitted:

```
Dependencies that need approval:

highline, 1.6.14, ruby
json, 1.7.5, ruby
mime-types, 1.19, ruby
rails, 3.2.8, unknown
rdoc, 3.12, unknown
rubyzip, 0.9.9, ruby
xml-simple, 1.1.1, unknown
```

You can customize the format of the output in the same way that you customize
[output from `report`](#output-from-report).

### Output from `project_roots`

The `license_finder project_roots` command will output the current working directory as a string in an array.

Using the `--recursive` option means the array will include subdirectories that contain a known package manager. With the exception that Gradle and Maven subprojects will not be included.


### Output from `report`

The `license_finder report` command will output human-readable reports that you
could send to your non-technical business partners, lawyers, etc.  You can
choose the format of the report (text, csv, html or markdown); see
`license_finder --help report` for details.  The output is sent to STDOUT, so
you can save the reports wherever you want them.  You can commit them to
version control if you like.

The HTML report generated by `license_finder report --format html` summarizes
all of your project's dependencies and includes information about which need to
be approved. The project name at the top of the report can be set with
`license_finder project_name add`.

### Note:
When using the yarn package manager, when a node_module's package.json doesn't
explicitly declare a license, yarn indicates that it has inferred the license based
on some keywords in other files by appending an asterisk to the license name. If you
see a * at the end of the license name, this is intended.

See [CONTRIBUTING.md](https://github.com/pivotal/LicenseFinder/blob/master/CONTRIBUTING.md#adding-reports)
for advice about adding and customizing reports.


## Manual Intervention

### Setting Licenses

When `license_finder` reports that a dependency's license is 'unknown',
you should manually research what the actual license is.  When you
have established the real license, you can record it with:

```sh
$ license_finder licenses add my_unknown_dependency MIT --homepage="www.unknown-code.org"
```

This command would assign the MIT license to the dependency
`my_unknown_dependency`. It will also set its homepage to `www.unknown-code.org`.


### Adding Hidden Dependencies

`license_finder` can track dependencies that your package managers
don't know about (JS libraries that don't appear in your
Gemfile/requirements.txt/package.json, etc.)

```sh
$ license_finder dependencies add my_js_dep MIT 0.1.2
```

Run `license_finder dependencies help` for
additional documentation about managing these dependencies.

`license_finder` cannot automatically detect when one of these
dependencies has been removed from your project, so you can use:

```sh
$ license_finder dependencies remove my_js_dep
```

### Excluding Dependencies

Sometimes a project will have development or test dependencies which
you don't want to track.  You can exclude theses dependencies by running
`license_finder ignored_groups`.  (Currently this only works for packages
managed by Bundler, NPM, Yarn, Maven, Pip2, Pip3, and Nuget.)

On rare occasions a package manager will report an individual dependency
that you want to exclude from all reports, even though it is approved.
You can exclude an individual dependency by running
`license_finder ignored_dependencies`.  Think carefully before adding
dependencies to this list.  A likely item to exclude is `bundler`,
since it is a common dependency whose version changes from machine to
machine.  Adding it to the `ignored_dependencies` would prevent it
(and its oscillating versions) from appearing in reports.

### Restricting Licenses

Some projects will have a list of licenses that cannot be used.  You can
restrict these licenses with `license_finder restricted_licenses add`.  Any dependency
that has exclusively restricted licenses will always appear in the action
items, even if someone attempts to manually approve or permit it.  However,
if a dependency has even one license that is not restricted, it can still be
manually approved or permitted.

## Decision inheritance

Add or remove decision files you want to inherit from - see `license_finder inherited_decisions help` for more information.

This allows you to have a centralized decision file for approved/restricted licenses. If you have multiple projects it's way easier to have one single place where you approved or restricted licenses defined.

Add one or more decision files to the inherited decisions
```bash
license_finder inherited_decisions add DECISION_FILE
```

Remove one or more decision files from the inherited decisions
```bash
license_finder inherited_decisions remove DECISION_FILE
```

List all the inherited decision files
```bash
license_finder inherited_decisions list
```

## Configuration

Be default, `license_finder` expects the decisions file to be stored at
`doc/dependency_decisions.yml`.  All commands can be passed `--decisions_file`
to override this location.

### Package Manager Configuration

If you have a gradle project, you can invoke gradle with a custom script by
passing (for example) `--gradle_command gradlew` to `license_finder` or
`license_finder report`.

Similarly you can invoke a custom rebar script with `--rebar_command rebar`.
If you store rebar dependencies in a custom directory (by setting `deps_dir` in
`rebar.config`), set `--rebar_deps_dir`.

You can also invoke a custom Mix script `remix` with `--mix_command remix` and
set `--mix_deps_dir` to fetch Mix dependencies from a custom directory.

### Narrow down Package Manager

By default, license_finder will check for all supported package managers,
but you can narrow it down to use only those you pass to `--enabled-package-managers`.
For example,

```
$ license_finder --enabled-package-managers bundler npm
```

### Saving Configuration

It may be difficult to remember to pass command line options to every command.
In some of these cases you can store default values in a YAML formatted config
file. `license_finder` looks for this file in `config/license_finder.yml`.

As an example, the file might look like this:

```yaml
---
decisions_file: './some_path/decisions.yml'
gradle_command: './gradlew'
rebar_command: './rebarw'
rebar_deps_dir: './rebar_deps'
mix_command: './mixw'
mix_deps_dir: './mix_deps'
enabled_package_managers:
  - bundler
  - gradle
  - rebar
  - mix
```

### Gradle Projects

`license_finder` supports both Gradle 1.x and Gradle 2.x. You need to have installed
the license-gradle-plugin in your project:
[https://github.com/hierynomus/license-gradle-plugin](https://github.com/hierynomus/license-gradle-plugin)

By default, `license_finder` will report on Gradle's "runtime" dependencies. If
you want to generate a report for some other dependency configuration (e.g.
Android projects will sometimes specify their meaningful dependencies in the
"compile" group), you can specify it in your project's `build.gradle`:

```
// Must come *after* applying the appropriate plugin from [https://github.com/hierynomus/license-gradle-plugin](https://github.com/hierynomus/license-gradle-plugin)

downloadLicenses {
  dependencyConfiguration "compile"
}
```

### Conan Projects

`license_finder` supports Conan. You need to have the following lines in your conanfile.txt for `license_finder` to retrieve dependencies' licenses.
Ensure that `conan install` does not generate an error.

```
[imports]
., license* -> ./licenses @ folder=True, ignore_case=True
```

### SBT Projects

`license_finder` supports SBT. You need to have installed the sbt-license-report in your project:
[https://github.com/sbt/sbt-license-report](https://github.com/sbt/sbt-license-report)

By default, `license_finder` will report on SBT's "compile" and "test" dependencies. If
you want to generate a report for some other dependency configuration, you can specify
it in your projects's `build.sbt`

```
licenseConfigurations := Set("compile", "provided")
```

## Requirements

`license_finder` requires ruby >= 1.9.3, or jruby.


## Upgrading

To upgrade to `license_finder` version >= 6.0, you have to replace the terminology `whitelist` with `permit` and  `blacklist` with `restrict` in your `dependency_decisions.yml`. See [Changelog](https://github.com/pivotal/LicenseFinder/blob/master/CHANGELOG.md#600--2020-01-22) for more details.

To upgrade from `license_finder` version 1.2 to 2.0, see
[`license_finder_upgrade`](https://github.com/mainej/license_finder_upgrade).
To upgrade to 2.0 from a version lower than 1.2, first upgrade to 1.2, and run
`license_finder` at least once.  This will ensure that the `license_finder`
database is in a state which `license_finder_upgrade` understands.


## A Plea to Package Authors and Maintainers

Please add a license to your package specs! Most packaging systems
allow for the specification of one or more licenses.

For example, Ruby Gems can specify a license by name:

```ruby
Gem::Specification.new do |s|
  s.name = "my_great_gem"
  s.license = "MIT"
end
```

And save a `LICENSE` file which contains your license text in your repo.

## Known issues with specific package managers

* Bundler
   * When using `--project-path`, Bundler cannot find the Gemfile.

* Yarn
   * A module that is incompatible with the platform on which
     license_finder is run will always be reported to have a license type
     of "unknown". ([#456](https://github.com/pivotal/LicenseFinder/issues/456))

## Support

* Send an email to the list: [license-finder@googlegroups.com](license-finder@googlegroups.com)
* View the project backlog at Pivotal Tracker: [https://www.pivotaltracker.com/n/projects/234851](https://www.pivotaltracker.com/n/projects/234851)


## Contributing

See [CONTRIBUTING.md](https://github.com/pivotal/LicenseFinder/blob/master/CONTRIBUTING.md).


## License

LicenseFinder is released under the MIT License. http://www.opensource.org/licenses/mit-license
