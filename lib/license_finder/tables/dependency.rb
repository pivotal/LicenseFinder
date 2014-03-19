module LicenseFinder
  class Dependency < Sequel::Model
    plugin :boolean_readers
    plugin :composition
    composition :license,
      composer: ->(d) { License.find_by_name(d.license_name) },
      decomposer: ->(d) { self.license_name = license.name }

    many_to_many :children, join_table: :ancestries, left_key: :parent_dependency_id, right_key: :child_dependency_id, class: self
    many_to_many :parents, join_table: :ancestries, left_key: :child_dependency_id, right_key: :parent_dependency_id, class: self
    many_to_many :bundler_groups

    dataset_module do
      def managed
        manually_managed.invert
      end

      def manually_managed
        where(manual: true)
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

    def approve!
      self.manually_approved = true
      save
    end

    def approved?
      license.whitelisted? || manually_approved?
    end

    def set_license_manually!(license_name)
      self.license = License.find_by_name(license_name)
      self.license_manual = true
      save
    end

    def apply_better_license(license_name)
      return if license_manual
      if license.nil? || license.name != license_name
        self.license = License.find_by_name(license_name)
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

