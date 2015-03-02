# Contributing

## TL;DR

* Fork the project from https://github.com/pivotal/LicenseFinder
* Create a feature branch.
* Make your feature addition or bug fix. Please make sure there is appropriate test coverage.
* Rebase on top of master.
* Send a pull request.


## Adding Package Managers

There are a few steps to adding a new package manager.
[Here](https://github.com/pivotal/LicenseFinder/compare/v2.0.0...v2.0.1) is how
support was added for `rebar`, an `erlang` package manager.


## Adding Licenses

Add new licenses to `lib/license_finder/license/definitions.rb`.  There are
existing tools for matching licenses; see, for example, the MIT license, which
can be detected in many different ways.


## Adding Reports

If you need `license_finder` to output additional data, consider adding new
columns to `lib/license_finder/reports/csv_report.rb`.


## Development Dependencies

To successfully run the test suite, you will need npm, maven, pip, gradle and
bower installed. If you run `rake check_dependencies`, you'll see exactly what
you're missing.

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
