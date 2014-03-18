require 'digest'

module LicenseFinder
  module DependencyManager
    def self.sync_with_package_managers
      modifying {
        current_dependencies = PackageSaver.save_all(current_packages)

        Dependency.managed.obsolete(current_dependencies).each(&:destroy)
      }
    end

    def self.create_manually_managed(license, name, version)
      raise Error.new("#{name} dependency already exists") unless Dependency.where(name: name).empty?

      modifying {
        dependency = Dependency.new(added_manually: true, name: name, version: version)
        dependency.license = LicenseAlias.named(license)
        dependency.save
      }
    end

    def self.destroy_manually_managed(name)
      modifying { find_by_name(name, Dependency.manually_managed).destroy }
    end

    def self.license!(name, license)
      modifying { find_by_name(name).set_license_manually!(license) }
    end

    def self.approve!(name)
      modifying { find_by_name(name).approve!  }
    end

    def self.modifying
      checksum_before_modifying = if File.exists? LicenseFinder.config.database_uri
                                    Digest::SHA2.file(LicenseFinder.config.database_uri).hexdigest
                                  end
      result = yield
      checksum_after_modifying = Digest::SHA2.file(LicenseFinder.config.database_uri).hexdigest

      unless checksum_after_modifying == checksum_before_modifying
        Reporter.write_reports
      end
      unless File.exists? LicenseFinder.config.dependencies_html
        Reporter.write_reports
      end

      result
    end

    private # not really private, but it looks like it is!

    def self.current_packages
      package_managers.select(&:active?).map(&:current_packages).flatten
    end

    def self.package_managers
      [Bundler, NPM, Pip, Bower]
    end

    def self.find_by_name(name, scope = Dependency)
      dep = scope.first(name: name)
      raise Error.new("could not find dependency named #{name}") unless dep
      dep
    end
  end
end

