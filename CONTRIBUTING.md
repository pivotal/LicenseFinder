# Contributing

## TL;DR

* Fork the project from https://github.com/pivotal/LicenseFinder
* Create a feature branch.
* Make your feature addition or bug fix. Please make sure there is appropriate test coverage.
* Rebase on top of master.
* Send a pull request with commit messages tagged with an entry specified here: https://keepachangelog.com/en/1.0.0/.

## Running Tests

You can use the [LicenseFinder docker image](https://hub.docker.com/r/licensefinder/license_finder/) to run the tests by using the `dlf` script.
There are 2 sets of tests to run in order to confirm that License Finder is working as intended:

```
./dlf rake spec
./dlf bundle exec rake features
```

The `spec` task runs all the unit test and the `features` task will run all the feature test.
Note that the feature test needs to be wrapped in `bundle exec`, or else it
will use the gem version installed inside the docker image.

## Useful Tips

To build the docker image simply call `docker build .` or explicitly pass the `Dockerfile`. Prebuilt versions of the
dockerfile can also be found on [Dockerhub](https://hub.docker.com/r/licensefinder/license_finder/tags/).

To launch the docker image and interact with it via bash:
```
docker run -v $PWD:/scan -it licensefinder/license_finder /bin/bash -l

```
`-v $PWD:/scan` will mount the current working directory to the /scan path.

## Adding Package Managers

There are a few steps to adding a new package manager.
The main things which need to be implemented are mentioned in [Package Manager](https://github.com/pivotal/LicenseFinder/blob/master/lib/license_finder/package_manager.rb).

[Here](https://github.com/pivotal/LicenseFinder/compare/v2.0.0...v2.0.1) is how
support was added for `rebar`, an `erlang` package manager.

There are feature tests and unit tests for each currently supported package manager.
* [Feature test example](https://github.com/pivotal/LicenseFinder/blob/master/features/features/package_managers/gvt_spec.rb)
* [Unit test example](https://github.com/pivotal/LicenseFinder/blob/master/spec/lib/license_finder/package_managers/gvt_spec.rb)

## Adding Licenses

Add new licenses to `lib/license_finder/license/definitions.rb`.  There are
existing tools for matching licenses; see, for example, the MIT license, which
can be detected in many different ways.


## Adding Reports

If you need `license_finder` to output additional package data, consider
submitting a pull request which adds new columns to
`lib/license_finder/reports/csv_report.rb`.

It is also possible to generate a custom report from an ERB template.  Use this
[example](https://github.com/pivotal/LicenseFinder/blob/master/examples/custom_erb_template.rb) as a starting
point.  These reports will have access to the helpers in
[`LicenseFinder::ErbReport`](https://github.com/pivotal/LicenseFinder/blob/master/lib/license_finder/reports/erb_report.rb).

If you need a report with more detailed data or in a different format, we
recommend writing a custom ruby script.  This
[example](https://github.com/pivotal/LicenseFinder/blob/master/examples/extract_license_data.rb) will get you
started.

If you come up with something useful, consider posting it to the Google Group
[license-finder@googlegroups.com](license-finder@googlegroups.com).


## Development Dependencies

To successfully run the test suite, you will need the following installed:
- NPM (requires Node)
- Yarn (requires Node)
- Bower (requires Node and NPM)
- Maven (requires Java)
- Gradle (requires Java)
- Pip (requires python)
- Rebar (requires erlang)
- GoDep, GoWorkspace, govendor, Glide, Dep, and Gvt (requires golang)
- CocoaPods (requires ruby)
- Bundler (requires ruby)
- Carthage (requires homebrew)
- Mix (requires Elixir)
- Conan
- NuGet
- dotnet
- Conda (requires python)

The [LicenseFinder docker image](https://hub.docker.com/r/licensefinder/license_finder/) already contains these dependencies.

If you run `rake check_dependencies`, you'll see exactly which package managers you're missing.

### Python

For the python dependency tests you will want to have virtualenv
installed, to allow pip to work without sudo. For more details, see
this [post on virtualenv][].

  [post on virtualenv]: http://hackercodex.com/guide/python-development-environment-on-mac-osx/#virtualenv

You'll need a pip version >= 6.0.

### JRuby

If you're running the test suite with jruby, you're probably going to
want to set up some environment variables:

```
JAVA_OPTS='-client -XX:+TieredCompilation -XX:TieredStopAtLevel=1' JRUBY_OPTS='-J-Djruby.launch.inproc=true'
```

### Gradle

You'll need a gradle version >= 1.8.
