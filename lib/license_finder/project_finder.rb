module LicenseFinder
  class ProjectFinder
    def initialize(main_project_path)
      @package_managers = LicenseFinder::PackageManager.package_managers
      @main_project_path = main_project_path
    end

    def find_projects
      [].tap do |paths|
        all_dirs = Dir.glob("#{@main_project_path}/**/").map {|path| full_path(path)}
        all_dirs.each do |potential_project_path|
          if active_project?(potential_project_path)
            paths << potential_project_path.to_s
          end
        end
      end
    end

    private

    def active_project?(project_path)
      active_project = @package_managers.map do |pm|
        pm.new(project_path: project_path).active?
      end
      active_project.include?(true)
    end

    def full_path(rel_path)
      Pathname.new(rel_path).expand_path
    end
  end
end
