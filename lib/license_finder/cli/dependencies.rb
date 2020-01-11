# frozen_string_literal: true

module LicenseFinder
  module CLI
    class Dependencies < Base
      extend Subcommand
      include MakesDecisions

      method_option :approve, type: :boolean, desc: 'Approve the added dependency'
      method_option :homepage, type: :string, desc: 'Source of the added dependency'

      auditable
      desc 'add DEPENDENCY LICENSE VERSION [--homepage=HOMEPAGE] [--approve]', 'Add a dependency that is not managed by a package manager, optionally approving it at the same time'
      def add(name, license, version)
        modifying do
          decisions
            .add_package(name, version, txn)
            .license(name, license, txn)
          decisions.homepage(name, options[:homepage], txn) if options[:homepage]
          decisions.approve(name, txn) if options[:approve]
        end
        if options[:approve]
          say "The #{name} dependency has been added and approved!", :green
        else
          say "The #{name} dependency has been added!", :green
        end
      end

      auditable
      desc 'remove DEPENDENCY', 'Remove a dependency that is not managed by a package manager'
      def remove(name)
        modifying { decisions.remove_package(name, txn) }

        say "The #{name} dependency has been removed.", :green
      end

      desc 'list', 'List manually added dependencies'
      def list
        say 'Manually Added Dependencies:', :blue
        say_each(decisions.packages, &:name)
      end
    end
  end
end
