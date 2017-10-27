module LicenseFinder
  module CLI
    class Whitelist < Base
      extend Subcommand
      include MakesDecisions

      desc 'list', 'List all the whitelisted licenses'
      def list
        say 'Whitelisted Licenses:', :blue
        say_each(decisions.whitelisted, &:name)
      end

      auditable
      desc 'add LICENSE...', 'Add one or more licenses to the whitelist'
      def add(*licenses)
        assert_some licenses
        modifying { licenses.each { |l| decisions.whitelist(l, txn) } }
        say "Added #{licenses.join(', ')} to the license whitelist"
      end

      auditable
      desc 'remove LICENSE...', 'Remove one or more licenses from the whitelist'
      def remove(*licenses)
        assert_some licenses
        modifying { licenses.each { |l| decisions.unwhitelist(l, txn) } }
        say "Removed #{licenses.join(', ')} from the license whitelist"
      end
    end
  end
end
