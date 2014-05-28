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
        dependency.license = License.find_by_name(license)
        dependency.save
      }
    end

    def self.manually_remove(name)
      modifying { find_by_name(name, Dependency.added_manually).destroy }
    end

    def self.license!(name, license_name)
      license = License.find_by_name(license_name)
      modifying { find_by_name(name).set_license_manually!(license) }
    end

    def self.approve!(name, approver = nil, notes = nil)
      modifying { find_by_name(name).approve!(approver, notes)  }
    end

    def self.modifying
      checksum_before = checksum
      result = DB.transaction { yield }
      checksum_after = checksum

      database_changed = checksum_before != checksum_after

      if database_changed || reports_do_not_exist || reports_are_stale
        Reporter.write_reports
      end

      result
    end

    private # not really private, but it looks like it is!

    def self.reports_do_not_exist
      !(LicenseFinder.config.artifacts.html_file.exist?)
    end

    def self.reports_are_stale
      LicenseFinder.config.last_modified > LicenseFinder.config.artifacts.last_refreshed
    end

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

    def self.checksum
      database_file = LicenseFinder.config.artifacts.database_file
      if database_file.exist?
        Digest::SHA2.file(database_file).hexdigest
      end
    end
  end
end

