# License Finder

[![Build Status](https://secure.travis-ci.org/pivotal/LicenseFinder.png)](http://travis-ci.org/pivotal/LicenseFinder)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/pivotal/LicenseFinder)

With bundler it's easy for your project to depend on many gems.  This decomposition is nice, but managing licenses becomes difficult.  This tool gathers info about the licenses of the gems in your project.

## Installation

Add license_finder to your Rails project's Gemfile and `bundle`:

```ruby
gem 'license_finder', git: "https://github.com/pivotal/LicenseFinder.git"
```

## Usage

License finder will generate reports of action items - i.e., dependencies that do not fall within your license "whitelist".

```sh
$ bundle exec license_finder
```

The first time you run this, `license_finder` will create a default configuration file `./config/license_finder.yml`:


```yaml
---
whitelist:
#- MIT
#- Apache 2.0
ignore_groups:
#- test
#- development
```

This allows you to configure bundler groups and add licenses to the whitelist.

On a brand new Rails project, you could expect `license_finder` to output something like the following
(assuming you whitelisted the MIT license in your `config/license_finder.yml`):

```
Dependencies that need approval:

highline, 1.6.14, ruby
json, 1.7.5, ruby
mime-types, 1.19, ruby
rails, 3.2.8, other
rdoc, 3.12, other
rubyzip, 0.9.9, ruby
xml-simple, 1.1.1, other
```

The executable task will also write out a dependencies.yml, dependencies.txt, and dependencies.html file in the root of your project.

The latter two files are human readable reports that you could send to your non-technical business partners, lawyers, etc.

`license_finder` will also return a non-zero exit status if there are
unapproved dependencies. You could use this in a CI build, for example, to alert you whenever someone adds an
unapproved dependency to the project.

It will also merge in an existing dependencies.yml file, if one exists (i.e., you've previously run this command
and then edited the resulting file).

### Manually recording licenses

When you have dependencies marked as having an 'other' license, `license_finder` will output
the license and readme file locations for the dependency, allowing you to manually research what the actual
license is. Once this has been established, you can record this information with the `-l` option
as such:

```sh
$ license_finder -l MIT my_unknown_dependency
```

This command would assign the MIT license to the dependency `my_unknown_dependency`.

### Manually approving dependencies

Whenever you have a dependency that falls outside of your whitelist, `license_finder` will tell you.
If your business decides that this is an acceptable risk, you can manually approve the dependency by using the `-a` or
`--approve` option of the `license_finder` command.

For example, lets assume you've only
whitelisted the "MIT" license in your `config/license_finder.yml`. You then add the 'awesome_gpl_gem' to your Gemfile,
which we'll assume is licensed with the `GPL` license. You then run `license_finder` and see
the gem listed in the output:

```txt
awesome_gpl_gem, 1.0.0, GPL
```

Your business tells you that in this case, it's acceptable to use this gem. You now run:

```sh
$ bundle exec license_finder -a awesome_gpl_gem
```

If you rerun `license_finder`, you should no longer see `awesome_gpl_gem` in the output.


## A note to gem authors / maintainers

For the good of humanity, please add a license to your gemspec!

```ruby
Gem::Specification.new do |s|
  s.name = "my_great_gem"
  s.license = "MIT"
end
```

And add a `LICENSE` file to your gem that contains your license text.

## License

LicenseFinder is released under the MIT License. http://www.opensource.org/licenses/mit-license
