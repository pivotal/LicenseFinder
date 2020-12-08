# frozen_string_literal: true

require 'json'

module LicenseFinder
  class Spm < PackageManager
    class SpmError < RuntimeError; end

    def current_packages
      unless File.exist?(workspace_state_path)
        raise SpmError, 'No checked-out SPM packages found.
          Please install your dependencies first.'
      end

      workspace_state = JSON.parse(IO.read(workspace_state_path))
      workspace_state['object']['dependencies'].map do |dependency|
        package_ref = dependency['packageRef']
        checkout_state = dependency['state']['checkoutState']

        subpath = dependency['subpath']
        package_name = package_ref['name']
        package_version = checkout_state['version'] || checkout_state['revision']
        homepage = package_ref['path']

        SpmPackage.new(
          package_name,
          package_version,
          license_text(subpath),
          logger: logger,
          install_path: project_checkout(subpath),
          homepage: homepage
        )
      end
    end

    def package_management_command
      LicenseFinder::Platform.darwin? ? 'xcodebuild' : 'swift'
    end

    def prepare_command
      LicenseFinder::Platform.darwin? ? 'xcodebuild -resolvePackageDependencies' : 'swift package resolve'
    end

    def possible_package_paths
      [workspace_state_path]
    end

    private

    def resolved_package
      if File.exist?(resolved_path)
        @resolved_file ||= IO.read(resolved_path)
      else
        raise SpmError, 'No Package.resolved found.
          Please install your dependencies first and provide it via environment variable
          SPM_PACKAGE_RESOLVED'
      end
    end

    def resolved_path
      # Xcode projects have SPM packages info under project's derived data location
      derived_data_folder = ENV['SPM_DERIVED_DATA']
      if derived_data_folder
        pathname = Pathname.new(derived_data_folder)
        pathname.absolute? ? pathname : project_path.join(derived_data_folder)
      else
        project_path.join('.build')
      end
    end

    def workspace_state_path
      resolved_path.join('workspace-state.json')
    end

    def license_text(subpath)
      license_path = license_pattern(subpath).find { |f| File.exist?(f) }
      license_path.nil? ? nil : IO.read(license_path)
    end

    def project_checkout(subpath)
      resolved_path.join('checkouts', subpath)
    end

    def license_pattern(subpath)
      checkout_path = project_checkout(subpath)
      Dir.glob(checkout_path.join('LICENSE*'), File::FNM_CASEFOLD)
    end

    def name_version_from_line(cartfile_line)
      cartfile_line.split(' ')[1, 2].map { |f| f.split('/').last.delete('"').gsub('.git', '') }
    end
  end
end
