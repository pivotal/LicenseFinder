# frozen_string_literal: true

module LicenseFinder
  module CLI
    class IgnoredGroups < Base
      extend Subcommand
      include MakesDecisions

      desc 'list', 'List all the ignored groups'
      def list
        printer.say 'Ignored Groups:', :blue
        say_each(decisions.ignored_groups)
      end

      auditable
      desc 'add GROUP', 'Add a group to be ignored'
      def add(group)
        modifying { decisions.ignore_group(group, txn) }

        printer.say "Added #{group} to the ignored groups"
      end

      auditable
      desc 'remove GROUP', 'Remove a group from the ignored groups'
      def remove(group)
        modifying { decisions.heed_group(group, txn) }

        printer.say "Removed #{group} from the ignored groups"
      end
    end
  end
end
