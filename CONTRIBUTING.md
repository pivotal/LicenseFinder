# Contributing

## TL;DR

* Fork the project from https://github.com/pivotal/LicenseFinder
* Create a feature branch.
* Make your feature addition or bug fix. Please make sure there is appropriate test coverage.
* Rebase on top of master.
* Send a pull request.


## Development Dependencies

To successfully run the test suite, you will need node.js, python, pip
and gradle installed. If you run `rake check_dependencies`, you'll see
exactly what you're missing.

### Python

For the python dependency tests you will want to have virtualenv
installed, to allow pip to work without sudo. For more details, see
this [post on virtualenv][].

  [post on virtualenv]: http://hackercodex.com/guide/python-development-environment-on-mac-osx/#virtualenv


### JRuby

If you're running the test suite with jruby, you're probably going to
want to set up some environment variables:

```
JAVA_OPTS='-client -XX:+TieredCompilation -XX:TieredStopAtLevel=1' JRUBY_OPTS='-J-Djruby.launch.inproc=true'
```

### Gradle

You'll need a gradle version >= 1.8.
