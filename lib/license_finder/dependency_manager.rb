module LicenseFinder
  module DependencyManager
    def self.sync_with_bundler
      modifying {
        current_dependencies = BundledGemSaver.save_gems(Bundle.current_gems(LicenseFinder.config))
        Dependency.bundler.obsolete(current_dependencies).each(&:destroy)
      }
    end

    def self.create_non_bundler(license, name, version)
      raise Error.new("#{name} dependency already exists") unless Dependency.where(name: name).empty?

      modifying {
        dependency = Dependency.new(manual: true, name: name, version: version)
        dependency.license = LicenseAlias.create(name: license)
        dependency.approval = Approval.create
        dependency.save
      }
    end

    def self.destroy_non_bundler(name)
      modifying { find_by_name(name, Dependency.non_bundler).destroy }
    end

    def self.license!(name, license)
      modifying { find_by_name(name).set_license_manually!(license) }
    end

    def self.approve!(name)
      modifying { find_by_name(name).approve!  }
    end

    def self.modifying
      timestamp_before_modifying = nil
      if File.exists? LicenseFinder.config.database_uri
        timestamp_before_modifying = File::Stat.new(LicenseFinder.config.database_uri).mtime.to_i
      end
      result = yield
      timestamp_after_modifying = File::Stat.new(LicenseFinder.config.database_uri).mtime.to_i

      unless timestamp_after_modifying == timestamp_before_modifying
        Reporter.write_reports
      end
      unless File.exists?(LicenseFinder.config.dependencies_html)
        Reporter.write_reports
      end

      result
    end

    private # not really private, but it looks like it is!

    def self.find_by_name(name, scope = Dependency)
      dep = scope.first(name: name)
      raise Error.new("could not find dependency named #{name}") unless dep
      dep
    end
  end
end

