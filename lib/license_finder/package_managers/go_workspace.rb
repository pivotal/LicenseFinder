require 'json'

module LicenseFinder
  class GoWorkspace < PackageManager
    Submodule = Struct.new :install_path, :revision
    ENVRC_REGEXP = /GOPATH|GO15VENDOREXPERIMENT/

    def initialize(options={})
      super
      @full_version = options[:go_full_version]
    end

    def current_packages
      go_list_packages = go_list
      git_modules.map do |submodule|
        # We are filtering the non-standard packages because the word "net"
        # seems to be common that can give false positive when filtering the git submodules
        import_path = go_list_packages.select { |gp|
          submodule.install_path =~ /#{repo_name(gp)}$/
        }.first
        if import_path then
          dependency_info = {
              'ImportPath' => repo_name(import_path),
              'Homepage' => repo_name(import_path),
              'InstallPath' => submodule.install_path,
              'Rev' => submodule.revision
          }
          GoPackage.from_dependency(dependency_info, nil, @full_version)
        end
      end.compact
    end

    def package_path
      envrc_path.dirname
    end

    def active?
      return false unless self.class.installed?(logger)

      godep = LicenseFinder::GoDep.new({project_path: Pathname(project_path)})
      # go workspace is only active if GoDep wasn't. There are some projects
      # that will use the .envrc and have a Godep folder as well.
      active = !! (!godep.active? && envrc_path && ENVRC_REGEXP.match(IO.read(envrc_path)))
      active.tap { |is_active| logger.active self.class, is_active }
    end

    private

    def repo_name import_path
      import_path.split("/")[0..2].join("/")
    end

    def project_src
      project_path.join('src')
    end

    def envrc_path
      p = Pathname.new project_path
      4.times.reduce([p]) { |memo, _| memo << memo.last.parent }.map { |p| p.join('.envrc') }.select(&:exist?).first
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
        raise 'go list failed' unless val.last
        # Select non-standard packages. `go list std` returns the list of standard
        # dependencies. We then filter those dependencies out of the full list of
        # dependencies.
        deps = val.first.split("\n")
        capture('go list std').first.split("\n").each do |std|
          deps.delete_if do |dep|
            dep =~ /(\/|^)#{std}(\/|$)/
          end
        end
        deps
      end
    end

    def git_modules
      Dir.chdir(package_path) do |d|
        result = capture('git submodule status')
        raise 'git submodule status failed' unless result[1]
        result.first.lines.map do |l|
          columns = l.split.map(&:strip)
          Submodule.new File.join(package_path, columns[1]), columns[0]
        end
      end
    end
  end
end
