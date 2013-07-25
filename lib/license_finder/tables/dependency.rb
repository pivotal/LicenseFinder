module LicenseFinder
  class Dependency < Sequel::Model
    plugin :boolean_readers
    many_to_one :license, class: LicenseAlias
    many_to_one :approval
    many_to_many :children, join_table: :ancestries, left_key: :parent_dependency_id, right_key: :child_dependency_id, class: self
    many_to_many :parents, join_table: :ancestries, left_key: :child_dependency_id, right_key: :parent_dependency_id, class: self
    many_to_many :bundler_groups

    dataset_module do
      def bundler
        exclude(manual: true)
      end

      def non_bundler
        bundler.invert
      end

      def obsolete(current)
        exclude(id: current.map(&:id))
      end
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

    def set_license_manually!(license_name)
      self.license = LicenseAlias.find_or_create(name: license_name)
      self.license_manual = true
      save
    end

    def ensure_approval_exists!
      return if approval
      self.approval = Approval.create
      save
    end
  end
end

