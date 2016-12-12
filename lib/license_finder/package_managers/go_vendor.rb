require 'json'

module LicenseFinder
  class GoVendor < PackageManager

    def initialize(options={})
      super
      @full_version = options[:go_full_version]
    end

    def active?
      return false unless self.class.installed?(@logger)

      (has_go_files? && package_path.exist?).tap do |is_active|
        logger.active self.class, is_active
      end
    end

    def has_go_files?
      !Dir[project_path.join("**/*.go")].empty?
    end

    def package_path
      project_path.join("vendor")
    end

    def project_sha(path)
      Dir.chdir(path) do
        val = capture('git rev-list --max-count 1 HEAD')
        raise 'git rev-list failed' unless val.last
        val.first.strip
      end
    end

    def current_packages
      deps = go_list
      vendored_deps = deps.select { |dep| package_path.join(dep).exist? }
      vendored_deps.map do |dep|
        GoPackage.from_dependency({
                                   'ImportPath' => dep,
                                   'InstallPath' => package_path.join(dep),
                                   'Rev' => 'vendored-' + project_sha(package_path.join(dep))
                                  }, nil, true)
      end
    end

    def self.package_management_command
      'go'
    end

    def go_list
      Dir.chdir(project_path) do
        # avoid checking canonical import path. some projects uses
        # non-canonical import path and rely on the fact that the deps are
        # checked in. Canonical paths are only checked by `go get'. We
        # discovered that `go list' will print a warning and unfortunately exit
        # with status code 1. Setting GOPATH to nil removes those warnings.
        ENV['GOPATH'] = nil
        val = capture('go list -f "{{join .Deps \"\n\"}}" ./...')
        return [] unless val.last
        # Select non-standard packages. `go list std` returns the list of standard
        # dependencies. We then filter those dependencies out of the full list of
        # dependencies.
        deps = val.first.split("\n")
        capture('go list std').first.split("\n").each do |std|
          deps.delete_if do |dep|
            dep =~ /(\/|^)#{std}(\/|$)/
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
