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
      modifying { find_by_name(name).license.set_manually(license) }
    end

    def self.approve!(name)
      modifying { find_by_name(name).approve!  }
    end

    private # not really private, but it looks like it is!

    def self.find_by_name(name, scope = Dependency)
      dep = scope.first(name: name)
      raise Error.new("could not find dependency named #{name}") unless dep
      dep
    end

    def self.modifying
      result = yield
      Reporter.write_reports
      result
    end
  end
end

