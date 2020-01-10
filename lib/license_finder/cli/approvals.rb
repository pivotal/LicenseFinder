# frozen_string_literal: true

module LicenseFinder
  module CLI
    class Approvals < Base
      extend Subcommand
      include MakesDecisions

      auditable
      approvable
      desc 'add DEPENDENCY...', 'Approve one or more dependencies by name'
      def add(*names)
        assert_some names
        modifying { names.each { |name| decisions.approve(name, txn) } }

        say "The #{names.join(', ')} dependency has been approved!", :green
      end

      auditable
      desc 'remove DEPENDENCY', 'Unapprove a dependency'
      def remove(dep)
        modifying { decisions.unapprove(dep, txn) }

        say "The dependency #{dep} no longer has a manual approval"
      end
    end
  end
end
