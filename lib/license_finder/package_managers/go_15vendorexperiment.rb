# frozen_string_literal: true

require 'json'

module LicenseFinder
  class Go15VendorExperiment < PackageManager
    def initialize(options = {})
      super
      @full_version = options[:go_full_version]
    end

    def active?
      super && go_files_exist?
    end

    def go_files_exist?
      !Dir[project_path.join('**/*.go')].empty? && !Dir[project_path.join('vendor/**/*.go')].empty?
    end

    def possible_package_paths
      [project_path.join('vendor')]
    end

    def project_sha(path)
      Dir.chdir(path) do
        stdout, _stderr, status = Cmd.run('git rev-list --max-count 1 HEAD')
        raise 'git rev-list failed' unless status.success?

        stdout.strip
      end
    end

    def current_packages
      deps = go_list
      vendored_deps = deps.select { |dep| detected_package_path.join(dep).exist? }
      vendored_deps.map do |dep|
        GoPackage.from_dependency({
                                    'ImportPath' => dep,
                                    'InstallPath' => detected_package_path.join(dep),
                                    'Rev' => 'vendored-' + project_sha(detected_package_path.join(dep)),
                                    'Homepage' => repo_name(dep)
                                  }, nil, true)
      end
    end

    def repo_name(name)
      name.split('/')[0..2].join('/')
    end

    def package_management_command
      'go'
    end

    def go_list
      Dir.chdir(project_path) do
        # avoid checking canonical import path. some projects uses
        # non-canonical import path and rely on the fact that the deps are
        # checked in. Canonical paths are only checked by `go get'. We
        # discovered that `go list' will print a warning and unfortunately exit
        # with status code 1. Setting GOPATH to nil removes those warnings.
        orig_gopath = ENV['GOPATH']
        ENV['GOPATH'] = nil
        val, _stderr, status = Cmd.run('go list -f "{{join .Deps \"\n\"}}" ./...')
        ENV['GOPATH'] = orig_gopath
        return [] unless status.success?

        # Select non-standard packages. `go list std` returns the list of standard
        # dependencies. We then filter those dependencies out of the full list of
        # dependencies.
        deps = val.split("\n")
        Cmd.run('go list std').first.split("\n").each do |std|
          deps.delete_if do |dep|
            dep =~ %r{(\/|^)#{std}(\/|$)}
          end
        end
        deps.map do |d|
          dep_parts = d.split('/')
          if dep_parts.length > 2
            dep_parts[0..2].join('/')
          else
            d
          end
        end
      end
    end
  end
end
