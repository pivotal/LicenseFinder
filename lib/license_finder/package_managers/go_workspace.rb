require 'json'

module LicenseFinder
  class GoWorkspace < PackageManager
    Submodule = Struct.new :install_path, :revision

    def initialize(options={})
      super
      @full_version = options[:go_full_version]
    end

    def current_packages
      go_list_packages = go_list
      git_modules.map do |submodule|
        import_path = go_list_packages.select { |gp|
          submodule.install_path =~ /#{repo_name(gp)}/
        }.first
        if import_path then
          GoPackage.from_dependency({
                                     'ImportPath' => repo_name(import_path),
                                     'InstallPath' => submodule.install_path,
                                     'Rev' => submodule.revision
                                    }, nil, @full_version)
        end
      end.compact
    end

    def package_path
      envrc_path.dirname
    end

    def active?
      go_dep = LicenseFinder::GoDep.new({project_path: Pathname(project_path), logger: logger})
      return if go_dep.package_path.exist?
      active = !!envrc_path && IO.read(envrc_path).include?('GOPATH')
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

    def go_list
      Dir.chdir(project_path) do
        ENV['GOPATH'] = package_path.to_s
        val = capture('go list -f \'{{join .Deps "\n"}}\' ./...')
        raise 'go list failed' unless val.last
        # Select non-standard packages. Standard packages tend to be short
        # and have less than two slashes
        val.first.lines.map(&:strip).select { |l| l.split("/").length > 2 }
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
