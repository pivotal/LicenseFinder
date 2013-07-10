## Tips on releasing

Build the gem for both ruby and jruby (use a later version of each ruby, if desired)


The first time you rvm install jruby, you may also have to bundle. This will require you to delete
any existing Gemfile.lock in the directory.


```sh
$ rvm use jruby-1.7.4
$ rake build
$ rvm use ruby-2.0.0
$ rake build
```

Push both versions of the gem

```sh
$ rake release # will push default MRI build of gem, and importantly, tag the gem
$ gem push pkg/license_finder-LATEST_VERSION_HERE-java.gem
```
