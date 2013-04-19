module LicenseFinder
  module DependencyManager
    def self.create_non_bundler(license, name, version)
      raise Error.new("#{name} dependency already exists") unless Dependency.where(name: name).empty?
      dependency = Dependency.new(manual: true, name: name, version: version)
      dependency.license = LicenseAlias.create(name: license)
      dependency.approval = Approval.create
      dependency.save
    end

    def self.clean_bundler_dependencies(current_dependencies)
      Dependency.bundler.obsolete(current_dependencies).each(&:destroy)
    end

    def self.destroy_non_bundler(name)
      find_by_name(name, Dependency.non_bundler).destroy
    end

    def self.license!(name, license)
      find_by_name(name).license.set_manually(license)
    end

    def self.approve!(name)
      find_by_name(name).approve!
    end

    def self.find_by_name(name, scope = Dependency)
      dep = scope.first(name: name)
      raise Error.new("could not find dependency named #{name}") unless dep
      dep
    end
  end
end

