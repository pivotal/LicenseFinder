module LicenseFinder
  class Dependency < Sequel::Model
    many_to_one :license, class: LicenseAlias
    many_to_one :approval
    many_to_many :children, join_table: :ancestries, left_key: :parent_dependency_id, right_key: :child_dependency_id, class: self
    many_to_many :parents, join_table: :ancestries, left_key: :child_dependency_id, right_key: :parent_dependency_id, class: self
    many_to_many :bundler_groups

    def self.destroy_obsolete(current_dependencies)
      exclude(id: current_dependencies.map(&:id)).each(&:destroy)
    end

    def self.unapproved
      all.reject(&:approved?)
    end

    def self.named(name)
      find_or_create(name: name.to_s) do |d|
        d.approval = Approval.create
      end
    end

    def approve!
      approval.state = true
      approval.save
    end

    def approved?
      (license && license.whitelisted?) || (approval && approval.state)
    end

    def set_license_manually(name)
      license.set_manually(name)
    end
  end
end

