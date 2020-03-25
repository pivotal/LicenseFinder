# frozen_string_literal: true

require 'json'

module LicenseFinder
  class GoWorkspacePackageManagerError < ::StandardError
  end

  class GoWorkspace < PackageManager
    Submodule = Struct.new :install_path, :revision
    ENVRC_REGEXP = /GOPATH|GO15VENDOREXPERIMENT/.freeze

    def initialize(options = {})
      super
      @full_version = options[:go_full_version]
      @strict_matching = options[:strict_matching]
    end

    def package_management_command
      'go'
    end

    def current_packages
      go_list_packages = go_list
      git_modules.map do |submodule|
        # We are filtering the non-standard packages because the word "net"
        # seems to be common that can give false positive when filtering the git submodules
        import_path = go_list_packages.find do |gp|
          submodule.install_path =~ /#{repo_name(gp)}$/
        end
        next unless import_path

        dependency_info = {
          'ImportPath' => repo_name(import_path),
          'Homepage' => repo_name(import_path),
          'InstallPath' => submodule.install_path,
          'Rev' => submodule.revision
        }
        GoPackage.from_dependency(dependency_info, nil, @full_version)
      end.compact
    end

    def self.takes_priority_over
      Go15VendorExperiment
    end

    def possible_package_paths
      [envrc_path.dirname]
    end

    def active?
      return false if @strict_matching

      godep = LicenseFinder::GoDep.new(project_path: Pathname(project_path))
      dep = LicenseFinder::Dep.new(project_path: Pathname(project_path))
      # go workspace is only active if GoDep wasn't. There are some projects
      # that will use the .envrc and have a Godep folder as well.
      !!(!godep.active? && !dep.active? && envrc_path && ENVRC_REGEXP.match(IO.read(envrc_path)))
    end

    private

    def repo_name(import_path)
      import_path.split('/')[0..2].join('/')
    end

    def project_src
      project_path.join('src')
    end

    def envrc_path
      p = Pathname.new project_path
      4.times.reduce([p]) { |memo, _| memo << memo.last.parent }.map { |path| path.join('.envrc') }.find(&:exist?)
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
        val, stderr, status = Cmd.run('go list -f "{{join .Deps \"\n\"}}" ./...')
        ENV['GOPATH'] = project_path.to_s
        val, stderr, status = Cmd.run('go list -f "{{join .Deps \"\n\"}}" ./...') unless status.success?
        ENV['GOPATH'] = orig_gopath
        raise GoWorkspacePackageManagerError, "go list failed:\n#{stderr}" unless status.success?

        # Select non-standard packages. `go list std` returns the list of standard
        # dependencies. We then filter those dependencies out of the full list of
        # dependencies.
        deps = val.split("\n")
        Cmd.run('go list std').first.split("\n").each do |std|
          deps.delete_if do |dep|
            dep =~ %r{(\/|^)#{std}(\/|$)}
          end
        end
        deps
      end
    end

    def git_modules
      Dir.chdir(detected_package_path) do |_d|
        result, _stderr, status = Cmd.run('git submodule status')
        raise 'git submodule status failed' unless status.success?

        result.lines.map do |l|
          columns = l.split.map(&:strip)
          Submodule.new File.join(detected_package_path, columns[1]), columns[0]
        end
      end
    end
  end
end
