module LicenseFinder
  module CLI
    class Licenses < Base
      extend Subcommand

      auditable
      desc "license DEPENDENCY_NAME LICENSE", "Update a dependency's license"
      def add(name, license)
        modifying { decisions.license(name, license, txn) }

        say "The #{name} dependency has been marked as using #{license} license!", :green
      end

      auditable
      desc "remove DEPENDENCY", "Remove a manually set license"
      def remove(dep)
        modifying { decisions.unlicense(dep, txn) }

        say "The dependency #{dep} no longer has a manual license"
      end
    end
  end
end
