Goal
====

With bundler it's easy for your project to depend on many gems.  This decomposition is nice, but managing licenses becomes difficult.  This tool gathers info about the licenses of the gems in your project.

Usage
=====

    cd ~
    git clone http://github.com/mainej/LicenseFinder.git license_finder
    cd your/project
    ~/license_finder/bin/license_finder

Optionally add `--with-licenses` to include the full text of the licenses in the output.

Sample Output
=============

    --- 
    json_pure 1.4.6: 
      dependency_name: json_pure
      dependency_version: 1.4.6
      install_path: /some/path/.rvm/gems/ruby-1.9.2-p0/gems/json_pure-1.4.6
      license_files: 
      - file_name: COPYING
        body_type: other
    --- 
    rake 0.8.7: 
      dependency_name: rake
      dependency_version: 0.8.7
      install_path: /some/path/.rvm/gems/ruby-1.9.2-p0/gems/rake-0.8.7
      license_files: 
      - file_name: MIT-LICENSE
        body_type: mit
        
