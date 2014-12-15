require 'digest'

module LicenseFinder
  class DependencyManager
    attr_reader :logger

    def initialize options={}
      @logger = options[:logger] || LicenseFinder::Logger::Default.new
      @decisions = options[:decisions]
    end

    def decisions
      @decisions ||= Decisions.saved!
    end

    def sync_with_package_managers options={}
      modifying {
        current_dependencies = PackageSaver.save_all(current_packages)

        Dependency.added_automatically.obsolete(current_dependencies).each(&:destroy)
      }
    end

    def manually_add(license, name, version)
      raise Error.new("#{name} dependency already exists") unless Dependency.where(name: name).empty?

      @decisions = decisions.
        add_package(name, version).
        license(name, license)

      modifying {
        dependency = Dependency.new(added_manually: true, name: name, version: version)
        dependency.licenses = [License.find_by_name(license)].to_set
        dependency.save
      }
    end

    def manually_remove(name)
      @decisions = decisions.remove_package(name)

      modifying { find_by_name(name, Dependency.added_manually).destroy }
    end

    def added_manually
      Dependency.added_manually
    end

    def license!(name, license_name)
      @decisions = decisions.license(name, license_name)
      license = License.find_by_name(license_name)
      modifying { find_by_name(name).set_license_manually!(license) }
    end

    def approve!(name, approver = nil, notes = nil)
      @decisions = decisions.approve(name)
      modifying { find_by_name(name).approve!(approver, notes)  }
    end

    def unapproved
      acknowledged.
        reject { |package| decisions.approved?(package.name) }.
        reject { |package| package.licenses.any? { |license| decisions.approved_license?(license) } }
    end

    def acknowledged
      # needs to be used in Reporter
      base_packages = decisions.packages + current_packages
      base_packages.
        map    { |package| with_decided_license(package) }.
        reject { |package| decisions.ignored?(package.name) }.
        reject { |package| package.groups.any? { |group| decisions.ignored_group?(group) } }
    end

    def modifying
      checksum_before = checksum
      result = DB.transaction { yield }
      decisions.save!
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
      package_managers.
        map { |pm| pm.new(logger: logger) }.
        select(&:active?).
        map(&:current_packages).
        flatten
    end

    def package_managers
      [Bundler, NPM, Pip, Bower, Maven, Gradle, CocoaPods]
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

    def with_decided_license(package)
      if license = decisions.license_of(package.name)
        package.decide_on_license license
      end
      package
    end

  end
end

