require 'digest'

module LicenseFinder
  module DependencyManager
    def self.sync_with_package_managers
      modifying {
        current_dependencies = PackageSaver.save_all(current_packages)

        Dependency.added_automatically.obsolete(current_dependencies).each(&:destroy)
      }
    end

    def self.manually_add(license, name, version)
      raise Error.new("#{name} dependency already exists") unless Dependency.where(name: name).empty?

      modifying {
        dependency = Dependency.new(added_manually: true, name: name, version: version)
        dependency.license = LicenseAlias.named(license)
        dependency.save
      }
    end

    def self.manually_remove(name)
      modifying { find_by_name(name, Dependency.added_manually).destroy }
    end

    def self.license!(name, license)
      modifying { find_by_name(name).set_license_manually!(license) }
    end

    def self.approve!(name)
      modifying { find_by_name(name).approve!  }
    end

    def self.modifying
      database_file = LicenseFinder.config.artifacts.database_file
      checksum_before_modifying = checksum(database_file)
      result = yield
      checksum_after_modifying = checksum(database_file)

      unless checksum_after_modifying == checksum_before_modifying
        Reporter.write_reports
      end
      unless LicenseFinder.config.artifacts.html_file.exist?
        Reporter.write_reports
      end

      result
    end

    private # not really private, but it looks like it is!

    def self.current_packages
      package_managers.select(&:active?).map(&:current_packages).flatten
    end

    def self.package_managers
      [Bundler, NPM, Pip, Bower, Maven, Gradle, CocoaPods]
    end

    def self.find_by_name(name, scope = Dependency)
      dep = scope.first(name: name)
      raise Error.new("could not find dependency named #{name}") unless dep
      dep
    end

    def self.checksum(database_file)
      if database_file.exist?
        Digest::SHA2.file(database_file).hexdigest
      end
    end
  end
end

