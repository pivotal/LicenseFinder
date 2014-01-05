## Release Script

There is now a release bash script that automates this process. You will need the necessary
rubies installed before performing the script in `release/publish.sh`

Only use the below steps if you are unable to use the publish script.

## Tips on releasing

Build the gem for both ruby and jruby (use a later version of each ruby, if desired)


The first time you rvm install jruby, you may also have to bundle. This will require you to delete
any existing Gemfile.lock in the directory.


```sh
$ rvm use jruby
$ rake build
$ rvm use ruby
$ rake build
```

Push both versions of the gem

```sh
$ rake release # will push default MRI build of gem, and importantly, tag the gem
$ gem push pkg/license_finder-LATEST_VERSION_HERE-java.gem
```
