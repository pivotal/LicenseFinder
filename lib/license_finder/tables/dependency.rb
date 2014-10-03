module LicenseFinder
  class Dependency < Sequel::Model
    plugin :boolean_readers
    plugin :composition
    composition :licenses,
      composer: ->(d) { [License.find_by_name(d.license_name)] },
      decomposer: ->(d) { self.license_name = licenses.first.name }

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
      acknowledged.reject(&:approved?)
    end

    def self.acknowledged
      ignored_dependencies = LicenseFinder.config.ignore_dependencies
      all.reject do |dependency|
        ignored_dependencies.include? dependency.name
      end
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
      whitelisted? || approved_manually?
    end

    def whitelisted?
      licenses.first.whitelisted?
    end

    def approved_manually?
      !!manual_approval
    end

    def set_licenses(other_licenses)
      return if license_assigned_manually?
      if licenses.first.name != other_licenses.first.name
        self.licenses = other_licenses
      end
    end

    def set_license_manually!(license)
      self.licenses = [license]
      self.license_assigned_manually = true
      save
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

