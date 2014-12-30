module LicenseFinder
  module CLI
    class Whitelist < Base
      extend Subcommand

      desc "list", "List all the whitelisted licenses"
      def list
        say "Whitelisted Licenses:", :blue
        say_each(decisions.whitelisted) { |license| license.name }
      end

      auditable
      desc "add LICENSE...", "Add one or more licenses to the whitelist"
      def add(license, *other_licenses)
        licenses = other_licenses.unshift license
        modifying {
          licenses.each do |license|
            decisions.whitelist(license, txn)
          end
        }
        say "Added #{licenses.join(", ")} to the license whitelist"
      end

      auditable
      desc "remove LICENSE...", "Remove one or more licenses from the whitelist"
      def remove(license, *other_licenses)
        licenses = other_licenses.unshift license
        modifying {
          licenses.each do |license|
            decisions.unwhitelist(license, txn)
          end
        }
        say "Removed #{licenses.join(", ")} from the license whitelist"
      end
    end
  end
end
