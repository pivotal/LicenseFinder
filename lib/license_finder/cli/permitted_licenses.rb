# frozen_string_literal: true

module LicenseFinder
  module CLI
    class PermittedLicenses < Base
      extend Subcommand
      include MakesDecisions

      desc 'list', 'List all the permitted licenses'
      def list
        say 'Permitted Licenses:', :blue
        say_each(decisions.permitted, &:name)
      end

      auditable
      desc 'add LICENSE...', 'Add one or more licenses to the permitted licenses'
      def add(*licenses)
        assert_some licenses
        modifying { licenses.each { |l| decisions.permit(l, txn) } }
        say "Added #{licenses.join(', ')} to the permitted licenses"
      end

      auditable
      desc 'remove LICENSE...', 'Remove one or more licenses from the permitted licenses'
      def remove(*licenses)
        assert_some licenses
        modifying { licenses.each { |l| decisions.unpermit(l, txn) } }
        say "Removed #{licenses.join(', ')} from the license permitted licenses"
      end
    end
  end
end
