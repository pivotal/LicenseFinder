require 'json'

module LicenseFinder
  class GoWorkspace < PackageManager
    Submodule = Struct.new :path, :revision

    def initialize(options={})
      super
      @full_version = options[:go_full_version]
    end

    def current_packages

      package_src = package_path.join('src')
      submodules.map do |submodule|
        import_path = Pathname.new(submodule.path).relative_path_from(package_src)
        GoPackage.from_dependency({'ImportPath' => import_path.to_s, 'Rev' => submodule.revision}, package_src, @full_version)
      end
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

    def submodules
      go_list_packages = go_list
      git_modules.reject do |git_module|
        go_list_packages.select { |gp|
          git_module.path =~ /#{gp.split("/")[0..2].join("/")}/
        }.empty?
      end

    end
  end
end
