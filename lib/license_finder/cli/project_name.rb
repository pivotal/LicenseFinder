# frozen_string_literal: true

module LicenseFinder
  module CLI
    class ProjectName < Base
      extend Subcommand
      include MakesDecisions

      desc 'show', 'Show the project name'
      def show
        printer.say 'Project Name:', :blue
        printer.say decisions.project_name
      end

      auditable
      desc 'add NAME', 'Set the project name'
      def add(name)
        modifying { decisions.name_project(name, txn) }

        printer.say "Set the project name to #{name}", :green
      end

      auditable
      desc 'remove', 'Remove the project name'
      def remove
        modifying { decisions.unname_project(txn) }

        printer.say 'Removed the project name'
      end
    end
  end
end
