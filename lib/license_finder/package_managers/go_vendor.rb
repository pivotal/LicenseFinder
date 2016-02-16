require 'json'

module LicenseFinder
  class GoVendor < PackageManager

    def initialize(options={})
      super
      @full_version = options[:go_full_version]
    end

    def active?
      !Dir[project_path.join("**/*.go")].empty? && package_path.exist?
    end

    def package_path
      project_path.join("vendor")
    end

    def project_sha
      @project_sha ||= Dir.chdir(project_path) do
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
                                   'Rev' => 'vendored-' + project_sha
                                  }, nil, true)
      end
    end


    def go_list
      Dir.chdir(project_path) do
        # avoid checking canonical import path. some projects uses
        # non-canonical import path and rely on the fact that the deps are
        # checked in. Canonical paths are only checked by `go get'. We
        # discovered that `go list' will print a warning and unfortunately exit
        # with status code 1. Setting GOPATH to nil removes those warnings.
        ENV['GOPATH'] = nil
        val = capture('go list -f \'{{join .Deps "\n"}}\' ./...')
        return [] unless val.last
        # Select non-standard packages. Standard packages tend to be short
        # and have less than two slashes
        val.first.lines.map(&:strip).select { |l| l.split("/").length > 2 }.map { |l| l.split("/")[0..2].join("/") }.uniq
      end
    end
  end
end
