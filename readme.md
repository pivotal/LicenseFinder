# License Finder

[![Build Status](https://secure.travis-ci.org/pivotal/LicenseFinder.png)](http://travis-ci.org/pivotal/LicenseFinder)
[![Code Climate](https://codeclimate.com/github/pivotal/LicenseFinder.png)](https://codeclimate.com/github/pivotal/LicenseFinder)

With bundler it's easy for your project to depend on many gems.  This decomposition is nice, but managing licenses becomes difficult.  This tool gathers info about the licenses of the gems in your project.


## Installation

Add license_finder to your project's Gemfile and `bundle`:

```ruby
gem 'license_finder'
```


## Usage

License finder will generate reports of action items - i.e., dependencies that do not fall within your license "whitelist".

```sh
$ license_finder
```

(Note) If you wish to run license_finder without the progress spinner use the -q or --quiet option.

On a brand new Rails project, you could expect `license_finder` to output something like the following
(assuming you whitelisted the MIT license -- see [Configuration](#configuration)):

```yaml
Dependencies that need approval:

highline, 1.6.14, ruby
json, 1.7.5, ruby
mime-types, 1.19, ruby
rails, 3.2.8, other
rdoc, 3.12, other
rubyzip, 0.9.9, ruby
xml-simple, 1.1.1, other
```

The executable task will also write out a dependencies.db, dependencies.txt, and dependencies.html file in the doc/
directory (by default -- see [Configuration](#configuration)).

The latter two files are human readable reports that you could send to your non-technical business partners, lawyers, etc.

`license_finder` will also return a non-zero exit status if there are
unapproved dependencies. You could use this in a CI build, for example, to alert you whenever someone adds an
unapproved dependency to the project.

Run `license_finder help` to see other available commands.

### Manually setting licenses

When `license_finder` reports that a dependency's license is 'other', you should manually research what the actual
license is.  When you have established the real license, you can record it with:

```sh
$ license_finder license MIT my_unknown_dependency
```

This command would assign the MIT license to the dependency `my_unknown_dependency`.

### Manually approving dependencies

Whenever you have a dependency that falls outside of your whitelist, `license_finder` will tell you.
If your business decides that this is an acceptable risk, you can manually approve the dependency by using the
`license_finder approve` command.

For example, lets assume you've only
whitelisted the "MIT" license in your `config/license_finder.yml`. You then add the `awesome_gpl_gem` to your Gemfile,
which we'll assume is licensed with the `GPL` license. You then run `license_finder` and see
the gem listed in the output:

```txt
awesome_gpl_gem, 1.0.0, GPL
```

Your business tells you that in this case, it's acceptable to use this gem. You now run:

```sh
$ license_finder approve awesome_gpl_gem
```

If you rerun `license_finder`, you should no longer see `awesome_gpl_gem` in the output.

### Managing ignored Bundler groups

Bundler groups can be added to an ignore list which will prevent LicenseFinder from evaluating their licenses.
These groups can be managed with the `ignored_bundler_groups` command.

To list currently ignored Bundler groups:

```sh
$ license_finder ignored_bundler_groups list
```

To add a group to the ignored Bundler groups:

```sh
$ license_finder ignored_bundler_groups add development
```

To remove a group from the ignored Bundler groups:

```sh
$ license_finder ignored_bundler_groups remove development
```

### Managing non-Bundler dependencies

license_finder can track dependencies that Bundler doesn't know about (JS libraries that don't
appear in your Gemfile, etc.)

```sh
$ license_finder dependencies add MIT my_js_dep 0.1.2
```

To automatically approve a non-bundler dependency when you add it, use:

```sh
$ license_finder dependencies add MIT my_js_dep 0.1.2 --approve
```

The version is optional.  Run `license_finder dependencies help` for additional documentation about
managing non-Bundler dependencies.

license_finder cannot automatically detect when a non-Bundler dependency has been removed from your
project, so you can use:

```sh
$ license_finder dependencies remove my_js_dep
```

## Configuration

The first time you run `license_finder` it will create a default configuration file `./config/license_finder.yml`:

```yaml
---
whitelist:
#- MIT
#- Apache 2.0
ignore_groups:
#- test
#- development
dependencies_file_dir: './doc/'
```

By modifying this file, you can configure license_finder's behavior. `Whitelisted` licenses will be automatically approved
and `ignore_groups` will limit which dependencies are included in your license report.  You can store the license database
and text files in another directory by changing `dependencies_file_dir`.


## Upgrade for pre 0.8.0 users

If you wish to cleanup your root directory you can run:

```sh
$ license_finder move
```

This will move your dependencies.* files to the /doc directory and update the config.


## Compatibility

license_finder is compatible with ruby 1.9, and ruby 2.0. There is also experimental support for jruby.


## A note to gem authors / maintainers

For the good of humanity, please add a license to your gemspec!

```ruby
Gem::Specification.new do |s|
  s.name = "my_great_gem"
  s.license = "MIT"
end
```

And add a `LICENSE` file to your gem that contains your license text.


## Support

* Send an email to the list: [license-finder@googlegroups.com](license-finder@googlegroups.com)
* View the project backlog at Pivotal Tracker: [https://www.pivotaltracker.com/s/projects/234851](https://www.pivotaltracker.com/s/projects/234851)


## Contributing

* Fork the project
* Create a feature branch
* Make your feature addition or bug fix (with tests)
* Rebase on top of master
* Send a pull request

## License

LicenseFinder is released under the MIT License. http://www.opensource.org/licenses/mit-license
