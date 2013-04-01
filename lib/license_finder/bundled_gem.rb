module LicenseFinder
  class BundledGem
    LICENSE_FILE_NAMES = %w(LICENSE License Licence COPYING README Readme ReadMe)

    attr_reader :parents

    def initialize(spec, bundler_dependency = nil)
      @spec = spec
      @bundler_dependency = bundler_dependency
    end

    def name
      "#{dependency_name} #{dependency_version}"
    end

    def parents
      @parents ||= []
    end

    def dependency_name
      @spec.name
    end

    def dependency_version
      @spec.version.to_s
    end

    def children
      @children ||= @spec.dependencies.collect(&:name)
    end

    def determine_license
      return @spec.license if @spec.license

      license_files.map(&:license).compact.first || 'other'
    end

    def license_files
      paths_with_license_names = find_matching_files(LICENSE_FILE_NAMES)
      paths_for_license_files = paths_with_license_names.map do |path|
        File.directory?(path) ? paths_for_files_in_license_directory(path) : path
      end.flatten.uniq
      get_files_for_paths(paths_for_license_files)
    end

    def install_path
      @spec.full_gem_path
    end

    def sort_order
      dependency_name.downcase
    end

    def save_or_merge
      dep = if exists?
              existing_dep
            else
              new_dep
            end
      dep.version = @spec.version.to_s
      dep.summary = @spec.summary
      dep.description = @spec.description
      dep.homepage = @spec.homepage

      if dep.license
        unless dep.license.manual
          unless determine_license == 'other'
            dep.license.name = determine_license
          end
        end
      else
        dep.license = LicenseFinder::Dependency::License.create(name: determine_license)
      end
      dep.save

      dep.remove_all_bundler_groups

      if @bundler_dependency
        @bundler_dependency.groups.each { |group|
          dep.add_bundler_group LicenseFinder::Dependency::BundlerGroup.find_or_create(name: group.to_s)
        }
      end

      dep.remove_all_children

      children.each do |child|
        dep.add_child(LicenseFinder::Dependency.find_or_create(name: child.to_s))
      end

      dep
    end

    private

    def exists?
      ! LicenseFinder::Dependency.where(name: @spec.name).empty?
    end

    def new_dep
      dep = LicenseFinder::Dependency.new(name: @spec.name)
      dep.approval = LicenseFinder::Dependency::Approval.create
      dep
    end

    def existing_dep
      LicenseFinder::Dependency.first(name: @spec.name)
    end

    def find_matching_files(names)
      Dir.glob(File.join(install_path, '**', "*{#{names.join(',')}}*"))
    end

    def get_file_for_path(path)
      PossibleLicenseFile.new(install_path, path)
    end

    def paths_for_files_in_license_directory(path)
      entries_in_directory = Dir::entries(path).reject { |p| p.match(/^(\.){1,2}$/) }
      entries_in_directory.map { |entry_name| File.join(path, entry_name) }
    end

    def get_files_for_paths(paths_for_license_files)
      paths_for_license_files.map do |path|
        get_file_for_path(path)
      end
    end
  end
end
