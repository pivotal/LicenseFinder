module LicenseFinder
  module CLI
    class Approvals < Base
      extend Subcommand
      include MakesDecisions

      auditable
      desc "add DEPENDENCY...", "Approve one or more dependencies by name"
      def add(name, *other_names)
        names = modify_each(name, *other_names) do |name|
          decisions.approve(name, txn)
        end

        say "The #{names.join(", ")} dependency has been approved!", :green
      end

      auditable
      desc "remove DEPENDENCY", "Unapprove a dependency"
      def remove(dep)
        modifying { decisions.unapprove(dep, txn) }

        say "The dependency #{dep} no longer has a manual approval"
      end
    end
  end
end
