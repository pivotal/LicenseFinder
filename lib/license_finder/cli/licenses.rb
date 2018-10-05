# frozen_string_literal: true

module LicenseFinder
  module CLI
    class Licenses < Base
      extend Subcommand
      include MakesDecisions

      auditable
      desc 'add DEPENDENCY LICENSE', "Set a dependency's licenses, overwriting any license_finder has found"
      def add(name, license)
        modifying { decisions.license(name, license, txn) }

        say "The #{name} dependency has been marked as using #{license} license!", :green
      end

      auditable
      desc 'remove DEPENDENCY LICENSE', 'Remove a manually set license'
      def remove(dep, lic)
        modifying { decisions.unlicense(dep, lic, txn) }

        say "The dependency #{dep} no longer has a manual license"
      end
    end
  end
end
