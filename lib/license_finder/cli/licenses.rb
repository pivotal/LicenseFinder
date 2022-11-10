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

        version_info = options[:version] ? " with version #{options[:version]}" : ''
        printer.say "The #{name} dependency#{version_info} has been marked as using #{license} license!", :green
      end

      auditable
      method_option :version, desc: 'The version associated with the license'
      desc 'remove DEPENDENCY LICENSE', 'Remove a manually set license'
      def remove(dep, lic = nil)
        modifying { decisions.unlicense(dep, lic, txn) }

        version_info = options[:version] ? " with version #{options[:version]}" : ''
        suffix = lic ? " of #{lic}" : ''
        printer.say "The dependency #{dep}#{version_info} no longer has a manual license#{suffix}"
      end
    end
  end
end
