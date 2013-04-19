module LicenseFinder
  class Dependency < Sequel::Model
    plugin :boolean_readers
    many_to_one :license, class: LicenseAlias
    many_to_one :approval
    many_to_many :children, join_table: :ancestries, left_key: :parent_dependency_id, right_key: :child_dependency_id, class: self
    many_to_many :parents, join_table: :ancestries, left_key: :child_dependency_id, right_key: :parent_dependency_id, class: self
    many_to_many :bundler_groups

    def self.create_non_bundler(license, name, version)
      raise Error.new("#{name} dependency already exists") unless Dependency.where(name: name).empty?
      dependency = Dependency.new(manual: true, name: name, version: version)
      dependency.license = LicenseAlias.create(name: license)
      dependency.approval = Approval.create
      dependency.save
    end

    def self.destroy_non_bundler(name)
      dep = non_bundler.first(name: name)
      if dep
        dep.destroy
      else
        raise Error.new("could not find non-bundler dependency named #{name}")
      end
    end

    def self.license!(name, license)
      dep = first(name: name)
      if dep
        dep.license.set_manually(license)
      else
        raise Error.new("could not find dependency named #{name}")
      end
    end

    def self.approve!(name)
      dep = first(name: name)
      if dep
        dep.approve!
      else
        raise Error.new("could not find dependency named #{name}")
      end
    end

    def self.bundler
      exclude(manual: true)
    end

    def self.non_bundler
      bundler.invert
    end

    def self.destroy_obsolete(current_dependencies)
      bundler.exclude(id: current_dependencies.map(&:id)).each(&:destroy)
    end

    def self.unapproved
      all.reject(&:approved?)
    end

    def self.named(name)
      d = find_or_create(name: name.to_s)
      d.ensure_approval_exists!
      d
    end

    def approve!
      approval.state = true
      approval.save
    end

    def approved?
      (license && license.whitelisted?) || approval.state
    end

    def ensure_approval_exists!
      return if approval
      self.approval = Approval.create
      save
    end
  end
end

