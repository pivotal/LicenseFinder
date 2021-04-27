# frozen_string_literal: true

require 'license_finder/packages/go_package'

module LicenseFinder
  class GoModules < PackageManager
    PACKAGES_FILE = 'go.mod'

    class << self
      def takes_priority_over
        Go15VendorExperiment
      end
    end

    def active?
      mod_files?
    end

    def current_packages
      packages = packages_info.map do |package|
        name, version, install_path = package.split(',')
        read_package(install_path, name, version) if install_path.to_s != ''
      end.compact
      packages.reject do |package|
        Pathname(package.install_path).cleanpath == Pathname(project_path).cleanpath
      end
    end

    private

    def packages_info
      Dir.chdir(project_path) do
        # Explanations:
        # * Only list dependencies (packages not listed in the project directory)
        #   (.DepOnly)
        # * Ignore packages that have nil modules
        #   (.Module)
        # * Ignore standard library packages
        #   (not .Standard)
        # * Replacement modules are respected
        #   (or .Module.Replace .Module)
        # * Module cache directory or (vendored) package directory
        #   (or $mod.Dir .Dir)
        format_str = \
          '{{ if and (.DepOnly) (.Module) (not .Standard) }}'\
            '{{ $mod := (or .Module.Replace .Module) }}'\
            '{{ $mod.Path }},{{ $mod.Version }},{{ or $mod.Dir .Dir }}'\
          '{{ end }}'

        # The module list flag (`-m`) is intentionally not used here. If the module
        # dependency tree were followed, transitive dependencies that are never imported
        # may be included.
        #
        # Instead, the owning module is listed for each imported package. This better
        # matches the implementation of other Go package managers.
        #
        # TODO: Figure out a way to make the vendor directory work (i.e. remove the
        # -mod=readonly flag). Each of the imported packages gets listed separatly,
        # confusing the issue as to which package is the root of the module.
        go_list_cmd = "GO111MODULE=on go list -mod=readonly -deps -f '#{format_str}' ./..."
        info_output, stderr, status = Cmd.run(go_list_cmd)
        log_errors_with_cmd(go_list_cmd, "Getting the dependencies from go list failed \n\t#{stderr}") unless status.success?
        raise "Command '#{go_list_cmd}' failed to execute" unless status.success?

        # Since many packages may belong to a single module, #uniq is used to deduplicate
        info_output.split("\n").uniq
      end
    end

    def mod_files?
      mod_file_paths.any?
    end

    def mod_file_paths
      Dir[project_path.join(PACKAGES_FILE)]
    end

    def read_package(install_path, name, version)
      info = {
        'ImportPath' => name,
        'InstallPath' => install_path,
        'Rev' => version,
        'Homepage' => repo_name(name)
      }

      GoPackage.from_dependency(info, nil, true)
    end

    def repo_name(name)
      name.split('/')[0..2].join('/')
    end
  end
end
