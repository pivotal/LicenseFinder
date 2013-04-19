module LicenseFinder
  module DependencyManager
    def self.create_non_bundler(license, name, version)
      raise Error.new("#{name} dependency already exists") unless Dependency.where(name: name).empty?
      dependency = Dependency.new(manual: true, name: name, version: version)
      dependency.license = LicenseAlias.create(name: license)
      dependency.approval = Approval.create
      dependency.save
    end

    def self.destroy_non_bundler(name)
      dep = Dependency.non_bundler.first(name: name)
      if dep
        dep.destroy
      else
        raise Error.new("could not find non-bundler dependency named #{name}")
      end
    end

    def self.license!(name, license)
      dep = Dependency.first(name: name)
      if dep
        dep.license.set_manually(license)
      else
        raise Error.new("could not find dependency named #{name}")
      end
    end

    def self.approve!(name)
      dep = Dependency.first(name: name)
      if dep
        dep.approve!
      else
        raise Error.new("could not find dependency named #{name}")
      end
    end

    def self.clean_bundler_dependencies(current_dependencies)
      Dependency.bundler.obsolete(current_dependencies).each(&:destroy)
    end
  end
end

