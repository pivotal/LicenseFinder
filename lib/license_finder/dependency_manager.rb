require 'digest'

module LicenseFinder
  class DependencyManager
    def sync_with_package_managers
      modifying {
        current_dependencies = PackageSaver.save_all(current_packages)

        Dependency.added_automatically.obsolete(current_dependencies).each(&:destroy)
      }
    end

    def manually_add(license, name, version)
      raise Error.new("#{name} dependency already exists") unless Dependency.where(name: name).empty?

      modifying {
        dependency = Dependency.new(added_manually: true, name: name, version: version)
        dependency.licenses = [License.find_by_name(license)].to_set
        dependency.save
      }
    end

    def manually_remove(name)
      modifying { find_by_name(name, Dependency.added_manually).destroy }
    end

    def license!(name, license_name)
      license = License.find_by_name(license_name)
      modifying { find_by_name(name).set_license_manually!(license) }
    end

    def approve!(name, approver = nil, notes = nil)
      modifying { find_by_name(name).approve!(approver, notes)  }
    end

    def modifying
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

    def reports_do_not_exist
      !(LicenseFinder.config.artifacts.html_file.exist?)
    end

    def reports_are_stale
      LicenseFinder.config.last_modified > LicenseFinder.config.artifacts.last_refreshed
    end

    def current_packages
      package_managers.select(&:active?).map(&:current_packages).flatten
    end

    def package_managers
      [Bundler.new, NPM, Pip.new, Bower, Maven, Gradle, CocoaPods]
    end

    def find_by_name(name, scope = Dependency)
      dep = scope.first(name: name)
      raise Error.new("could not find dependency named #{name}") unless dep
      dep
    end

    def checksum
      database_file = LicenseFinder.config.artifacts.database_file
      if database_file.exist?
        Digest::SHA2.file(database_file).hexdigest
      end
    end
  end
end

