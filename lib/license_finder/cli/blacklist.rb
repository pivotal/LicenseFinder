module LicenseFinder
  module CLI
    class Blacklist < Base
      extend Subcommand
      include MakesDecisions

      desc 'list', 'List all the blacklisted licenses'
      def list
        say 'Blacklisted Licenses:', :blue
        say_each(decisions.blacklisted, &:name)
      end

      auditable
      desc 'add LICENSE...', 'Add one or more licenses to the blacklist'
      def add(*licenses)
        assert_some licenses
        modifying { licenses.each { |l| decisions.blacklist(l, txn) } }
        say "Added #{licenses.join(', ')} to the license blacklist"
      end

      auditable
      desc 'remove LICENSE...', 'Remove one or more licenses from the blacklist'
      def remove(*licenses)
        assert_some licenses
        modifying { licenses.each { |l| decisions.unblacklist(l, txn) } }
        say "Removed #{licenses.join(', ')} from the license blacklist"
      end
    end
  end
end
