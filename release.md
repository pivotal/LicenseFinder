## Tips on releasing

Build the gem for both ruby and jruby (use a later version of each ruby, if desired)

```sh
$ rvm use jruby-1.7.3-d19
$ rake build
$ rvm use ruby-1.9.3-p392
$ rake build
```

Push both versions of the gem

```sh
$ rake release # will push default MRI build of gem, and importantly, tag the gem
$ gem push pkg/license_finder-LATEST_VERSION_HERE-java.gem
```
