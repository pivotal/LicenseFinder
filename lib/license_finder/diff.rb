module LicenseFinder
  class Diff
    def self.compare(f1, f2)
      p1 = Set.new(build_packages(f1))
      p2 = Set.new(build_packages(f2))

      added = p2.difference(p1).to_a
      removed = p1.difference(p2).to_a
      unchanged = p1.intersection(p2).to_a

      [].tap do |packages|
        unchanged.each do |package|
          package_previous = find_package(p1, package)
          package_current = find_package(p2, package)

          if package_current.licenses == package_previous.licenses
            packages << PackageDelta.unchanged(package_current, package_previous)
          else
            packages << PackageDelta.removed(package_previous)
            packages << PackageDelta.added(package_current)
          end
        end

        added.each    { |package| packages << PackageDelta.added(package) }
        removed.each  { |package| packages << PackageDelta.removed(package) }
      end
    end

    private

    def self.build_packages(content)
      CSV.parse(content).map do |row|
        row.map!(&:strip)
        package = Package.new(row[0], row[1], spec_licenses: [row[2]])
        if row.count == 4
          MergedPackage.new(package, row[3].split(','))
        else
          package
        end
      end
    end

    def self.find_package(set, package)
      set.find { |p| p.eql? package}
    end
  end
end
