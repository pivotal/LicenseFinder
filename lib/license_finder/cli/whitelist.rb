module LicenseFinder
  module CLI
    class Whitelist < Base
      extend Subcommand
      include MakesDecisions

      desc "list", "List all the whitelisted licenses"
      def list
        say "Whitelisted Licenses:", :blue
        say_each(decisions.whitelisted) { |license| license.name }
      end

      auditable
      desc "add LICENSE...", "Add one or more licenses to the whitelist"
      def add(license, *other_licenses)
        licenses = modify_each(license, *other_licenses) do |l|
          decisions.whitelist(l, txn)
        end
        say "Added #{licenses.join(", ")} to the license whitelist"
      end

      auditable
      desc "remove LICENSE...", "Remove one or more licenses from the whitelist"
      def remove(license, *other_licenses)
        licenses = modify_each(license, *other_licenses) do |l|
          decisions.unwhitelist(l, txn)
        end
        say "Removed #{licenses.join(", ")} from the license whitelist"
      end
    end
  end
end
