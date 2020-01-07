# frozen_string_literal: true

module LicenseFinder
  module CLI
    class RestrictedLicenses < Base
      extend Subcommand
      include MakesDecisions

      desc 'list', 'List all the restricted licenses'
      def list
        say 'Restricted Licenses:', :blue
        say_each(decisions.restricted, &:name)
      end

      auditable
      desc 'add LICENSE...', 'Add one or more licenses to the restricted licenses'
      def add(*licenses)
        assert_some licenses
        modifying { licenses.each { |l| decisions.restrict(l, txn) } }
        say "Added #{licenses.join(', ')} to the restricted licenses"
      end

      auditable
      desc 'remove LICENSE...', 'Remove one or more licenses from the restricted licenses'
      def remove(*licenses)
        assert_some licenses
        modifying { licenses.each { |l| decisions.unrestrict(l, txn) } }
        say "Removed #{licenses.join(', ')} from the restricted licenses"
      end
    end
  end
end
