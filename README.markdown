# License Finder

[![Build Status](https://secure.travis-ci.org/pivotal/LicenseFinder.png)](http://travis-ci.org/pivotal/LicenseFinder)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/pivotal/LicenseFinder)

With bundler it's easy for your project to depend on many gems.  This decomposition is nice, but managing licenses becomes difficult.  This tool gathers info about the licenses of the gems in your project.

## Installation

Add license_finder to your Rails project's Gemfile and `bundle`:

```ruby
gem 'license_finder'
```

## Usage

License finder will generate reports of action items - i.e., dependencies that do not fall within your license "whitelist".

```sh
$ bundle exec rake license:action_items
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

On a brand new Rails project, you could expect `rake license:action_items` to output something like the following
(assuming you whitelisted the MIT license in your `config/license_finder.yml`):

```
Dependencies that need approval:

highline 1.6.14, ruby
json 1.7.5, ruby
mime-types 1.19, ruby
rails 3.2.8, other
rdoc 3.12, other
  license files:
    /Users/pivotal/.rvm/gems/ruby-1.9.3-p0@rubygems.org/gems/rdoc-3.12/LICENSE.rdoc
    /Users/pivotal/.rvm/gems/ruby-1.9.3-p0@rubygems.org/gems/rdoc-3.12/README.rdoc
    /Users/pivotal/.rvm/gems/ruby-1.9.3-p0@rubygems.org/gems/rdoc-3.12/test/README
  readme files:
    /Users/pivotal/.rvm/gems/ruby-1.9.3-p0@rubygems.org/gems/rdoc-3.12/README.rdoc
    /Users/pivotal/.rvm/gems/ruby-1.9.3-p0@rubygems.org/gems/rdoc-3.12/test/README
rubyzip 0.9.9, ruby
xml-simple 1.1.1, other
```

The rake task will also write out a dependencies.yml, dependencies.txt, and dependencies.html file in the root of your project.

The latter two files are human readable reports that you could send to your non-technical business partners, lawyers, etc.

`rake license:action_items` will also return a non-zero exit status if there are
unapproved dependencies. You could use this in a CI build, for example, to alert you whenever someone adds an
unapproved dependency to the project.

It will also merge in an existing dependencies.yml file, if one exists (i.e., you've previously run this command
and then edited the resulting file).

### Manually approving dependencies

Whenever you have a dependency that falls outside of your whitelist, `rake license:action_items` will tell you.
If your business decides that this is an acceptable risk, you can manually approve the dependency by finding its
section in the `dependencies.yml` file and setting its `approved` attribute to true. For example, lets assume you've only
whitelisted the "MIT" license in your `config/license_finder.yml`. You then add the 'awesome_gpl_gem' to your Gemfile,
which we'll assume is licensed with the `GPL` license. You then run `rake license_finder:action_items` and see
the gem listed in the output:

```txt
awesome_gpl_gem 1.0.0, GPL
```

Your business tells you that in this case, it's acceptable to use this gem. You should now update your `dependencies.yml`
file, setting the `approved` attribute to `true` for the `awesome_gpl_gem` section:

```yaml
- name: awesome_gpl_gem
  version: 1.0.0
  license: GPL
  approved: true
```

If you rerun `rake license:action_items`, you should no longer see `awesome_gpl_gem` in the output.


## Manually managing Javascript Dependencies

License Finder currently has no method for automatically detecting third-party javascript libraries in your application
and alerting you to license violations. However, you can manually add javascript dependencies to your `dependencies.yml`
file:

```yaml
- name: "my_javascript_library"
  version: "0.0.0"
  license: "GPL"
  approved: false
```

You could then update the "approved" attribute to true once you have signoff from your business. License Finder will
remember any manually added licenses between successive runs.


## Usage outside Rails

First, add license finder to your project's Gemfile:

```ruby
gem "license_finder"
```

Next, update your project's Rakefile with the license finder tasks:

```ruby
require 'bundler/setup'
require 'license_finder'
LicenseFinder.load_rake_tasks
```

You can now use the `rake license:init` and `rake license:action_items` rake tasks.

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

LicenseFinder is released under the terms of the MIT License. http://www.opensource.org/licenses/mit-license
