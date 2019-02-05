# frozen_string_literal: true

module LicenseFinder
  module CLI
    class ProjectName < Base
      extend Subcommand
      include MakesDecisions

      desc 'show', 'Show the project name'
      def show
        say 'Project Name:', :blue
        say decisions.project_name
      end

      auditable
      desc 'add NAME', 'Set the project name'
      def add(name)
        modifying { decisions.name_project(name, txn) }

        say "Set the project name to #{name}", :green
      end

      auditable
      desc 'remove', 'Remove the project name'
      def remove
        modifying { decisions.unname_project(txn) }

        say 'Removed the project name'
      end
    end
  end
end
