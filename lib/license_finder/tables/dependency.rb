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

    def bundler_group_names=(names)
      current_groups = names.map { |name| BundlerGroup.find_or_create(name: name) }

      remove, add = set_diff(bundler_groups, current_groups)

      remove.each { |g| remove_bundler_group(g) }
      add.each { |g| add_bundler_group(g) }
    end

    def children_names=(names)
      current_children = names.map { |name| Dependency.named(name) }

      remove, add = set_diff(children, current_children)

      remove.each { |c| remove_child(c) }
      add.each { |c| add_child(c) }
    end

    def approve!
      approval.state = true
      approval.save
    end

    def approved?
      # jruby adapter receives approval.state as Fixnum '0', which ruby evaluates
      # as truthy, so we catch this here for jruby support.
      (license && license.whitelisted?) || (approval.state && approval.state != 0)
    end

    def ensure_approval_exists!
      return if approval
      self.approval = Approval.create
      save
    end

    def set_license_manually!(license_name)
      self.license = LicenseAlias.find_or_create(name: license_name)
      self.license_manual = true
      save
    end

    def apply_better_license(license_name)
      return if license_manual
      if license.nil? || license_name != license.name
        self.license = LicenseAlias.find_or_create(name: license_name)
        save
      end
    end

    private

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

