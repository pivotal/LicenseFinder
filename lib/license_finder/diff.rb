module LicenseFinder
  class Diff
    def self.compare(f1, f2)
      p1 = Set.new(build_packages(f1))
      p2 = Set.new(build_packages(f2))

      added = p2.difference(p1).to_a
      removed = p1.difference(p2).to_a
      unchanged = p1.intersection(p2).to_a

      set_diff_states('added', added)
      set_diff_states('removed', removed)
      set_diff_states('unchanged', unchanged)

      unchanged.concat(added).concat(removed)
    end

    private

    def self.build_packages(content)
      CSV.parse(content).map do |dep|
        dep.map!(&:strip)
        Package.new(dep[0], dep[1], spec_licenses: [dep[2]])
      end
    end

    def self.set_diff_states(state, packages)
      packages.each do |package|
        package.status = state
      end
    end
  end
end
