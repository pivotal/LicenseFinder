Goal
====

With bundler it's easy for your project to depend on many gems.  This decomposition is nice, but managing licenses becomes difficult.  This tool gathers info about the licenses of the gems in your project.

Usage
=====

For a Rails project add license_finder to your Gemfile:
    gem 'license_finder', :git => "https://github.com/pivotal/LicenseFinder.git"

Run 'rake license:init'
This will create a config/license_finder.yml file that lets you configure license finder.  This is where you should add licenses which are allowed on the project, so they will be automatically approved.

Run 'rake license:generate_dependencies'
This will write out a dependencies.yml and dependencies.txt file in the root of your project. 
It will also merge in an existing dependencies.yml file, if one exists.

Run 'rake license:action_items'
This will output a list of unapproved dependencies to the console

Run 'rake license:action_items:ok'
This will return a non-zero exit status if there are unapproved dependencies. Great for CI.

As a standalone script:
    cd ~
    git clone http://github.com/pivotal/LicenseFinder.git license_finder
    cd your/project
    ~/license_finder/bin/license_finder

Optionally add `--with-licenses` to include the full text of the licenses in the output.

Sample Output
=============

dependencies.yml:

    ---
    - name: "json_pure"
      version: "1.5.1"
      license: "other"
      approved: false

    - name: "rake"
      version: "0.8.7"
      license: "MIT"
      approved: true

dependencies.txt:

    json_pure 1.5.1, other
    rake 0.8.7, MIT

bin/license_finder:

    ---
    json_pure 1.5.1:
      dependency_name: json_pure
      dependency_version: 1.5.1
      install_path: /some/path/.rvm/gems/ruby-1.9.2-p180/gems/json_pure-1.5.1
      license_files:
      - file_name: COPYING
        header_type: other
        body_type: other
        disclaimer_of_liability: other
      - file_name: COPYING-json-jruby
        header_type: other
        body_type: other
        disclaimer_of_liability: other
      readme_files:
      - file_name: README
        mentions_license: true
      - file_name: README-json-jruby.markdown
        mentions_license: false
    ---
    rake 0.8.7:
      dependency_name: rake
      dependency_version: 0.8.7
      install_path: /some/path/.rvm/gems/ruby-1.9.2-p180/gems/rake-0.8.7
      license_files:
      - file_name: MIT-LICENSE
        header_type: other
        body_type: mit
        disclaimer_of_liability: "mit: THE AUTHORS OR COPYRIGHT HOLDERS"
      readme_files:
      - file_name: README
        mentions_license: true

Gem Maintainers
===============

Please add a license to your gemspec!

    Gem::Specification.new do |s|
      s.name = "my_great_gem"
      s.license = "MIT"
    end