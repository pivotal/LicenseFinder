require 'json'

module LicenseFinder
  class GoWorkspace < PackageManager
    Submodule = Struct.new :path, :revision

    def initialize(options={})
      super
      @full_version = options[:go_full_version]
    end

    def current_packages
      submodules.map do |submodule|
        import_path = Pathname.new(submodule.path).relative_path_from(project_src)
        GoPackage.from_dependency({'ImportPath' => import_path.to_s, 'Rev' => submodule.revision}, project_src, @full_version)
      end
    end

    def package_path
      project_path.join('.envrc')
    end

    def active?
      active = package_path.exist? && IO.read(package_path).include?('GOPATH')
      active.tap { |is_active| logger.active self.class, is_active }
    end

    private

    def project_src
      project_path.join('src')
    end

    def submodules
      output = Dir.chdir(project_path) do |d|
        result = capture('git submodule status')
        raise 'git submodule status failed' unless result[1]
        result.first
      end
      output.lines.map do |gitmodule|
        columns = gitmodule.split.map(&:strip)
        Submodule.new File.join(project_path,columns[1]), columns[0]
      end
    end
  end
end
