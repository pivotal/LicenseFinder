module LicenseFinder
  module CLI
    class Dependencies < Base
      extend Subcommand

      method_option :approve, type: :boolean, desc: "Approve the added dependency"
      desc "add LICENSE DEPENDENCY_NAME [VERSION] [--approve]", "Add a dependency that is not managed by a package manager, optionally approving it at the same time"
      def add(license, name, version = nil)
        modifying {
          decisions.
            add_package(name, version, txn).
            license(name, license, txn)
          decisions.approve(name, txn) if options[:approve]
        }
        if options[:approve]
          say "The #{name} dependency has been added and approved!", :green
        else
          say "The #{name} dependency has been added!", :green
        end
      end

      desc "remove DEPENDENCY_NAME", "Remove a dependency that is not managed by a package manager"
      def remove(name)
        modifying { decisions.remove_package(name, txn) }

        say "The #{name} dependency has been removed.", :green
      end

      desc "list", "List manually added dependencies"
      def list
        say "Manually Added Dependencies:", :blue
        say_each(decisions.packages) { |package| package.name }
      end
    end
  end
end
