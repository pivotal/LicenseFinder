# frozen_string_literal: true

module LicenseFinder
  module CLI
    class Licenses < Base
      extend Subcommand
      include MakesDecisions

      auditable
      method_option :version, desc: 'The version associated with the license'
      desc 'add DEPENDENCY LICENSE', "Set a dependency's licenses, overwriting any license_finder has found"
      def add(name, license)
        modifying { decisions.license(name, license, txn) }

        if options[:version]
          printer.say "The #{name} dependency with version #{options[:version]} has been marked as using #{license} license!", :green
        else
          printer.say "The #{name} dependency has been marked as using #{license} license!", :green
        end
      end

      auditable
      method_option :version, desc: 'The version associated with the license'
      desc 'remove DEPENDENCY LICENSE', 'Remove a manually set license'
      def remove(dep, lic)
        modifying { decisions.unlicense(dep, lic, txn) }

        if options[:version]
          printer.say "The dependency #{dep} with version #{options[:version]} no longer has a manual license of #{lic}"
        else
          printer.say "The dependency #{dep} no longer has a manual license of #{lic}"
        end
      end
    end
  end
end
