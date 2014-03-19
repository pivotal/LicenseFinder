module LicenseFinder
  class Dependency < Sequel::Model
    plugin :boolean_readers
    many_to_one :license, class: LicenseAlias
    one_to_one :manual_approval
    many_to_many :children, join_table: :ancestries, left_key: :parent_dependency_id, right_key: :child_dependency_id, class: self
    many_to_many :parents, join_table: :ancestries, left_key: :child_dependency_id, right_key: :parent_dependency_id, class: self
    many_to_many :bundler_groups

    dataset_module do
      def added_automatically
        added_manually.invert
      end

      def added_manually
        where(added_manually: true)
      end

      def obsolete(current)
        exclude(id: current.map(&:id))
      end
    end

    def self.unapproved
      all.reject(&:approved?)
    end

    def self.named(name)
      find_or_create(name: name.to_s)
    end

    def bundler_group_names=(names)
      update_association_collection(:bundler_groups, names)
    end

    def children_names=(names)
      update_association_collection(:children, names)
    end

    def approve!(approver = nil, notes = nil)
      self.manual_approval = ManualApproval.new(approver: approver, notes: notes)
      save
    end

    def approved?
      (license && license.whitelisted?) || approved_manually?
    end

    def approved_manually?
      !!manual_approval
    end

    def set_license_manually!(license_name)
      self.license = LicenseAlias.named(license_name)
      self.license_assigned_manually = true
      save
    end

    def apply_better_license(license_name)
      return if license_assigned_manually?
      if license.nil? || license.name != license_name
        self.license = LicenseAlias.named(license_name)
      end
    end

    private

    def update_association_collection(association_name, names)
      association = model.association_reflection(association_name)
      current_records = names.map { |name| association.associated_class.named(name) }

      remove, add = set_diff(public_send(association_name), current_records)

      remove.each { |r| public_send(association.remove_method, r) }
      add.each { |r| public_send(association.add_method, r) }
    end

    # Foreign method, belongs on Set
    #
    # Returns a pair of sets, which contain the elements that would have to be
    # removed from (and respectively added to) the first set in order to obtain
    # the second set.
    def set_diff(older, newer)
      return older - newer, newer - older
    end
  end
end

