require 'thor'

module LicenseFinder
  module CLI
    class Base < Thor
      def self.subcommand(namespace, klass, namespace_description)
        description = "#{namespace} [#{(klass.tasks.keys - ["help"]).join("|")}]"
        desc description, "#{namespace_description} - see `license_finder #{namespace} help` for more information"
        super namespace, klass
      end

      private

      def die_on_error
        yield
      rescue LicenseFinder::Error => e
        say e.message, :red
        exit 1
      end
    end

    class Dependencies < Base
      desc "add LICENSE DEPENDENCY_NAME [VERSION]", "Add a dependency that is not managed by Bundler"
      def add(license, name, version = nil)
        die_on_error {
          DependencyManager.create_non_bundler(license, name, version)
        }

        say "The #{name} dependency has been added!", :green
      end

      desc "remove DEPENDENCY_NAME", "Remove a dependency that is not managed by Bundler"
      def remove(name)
        die_on_error {
          DependencyManager.destroy_non_bundler(name)
        }

        say "The #{name} dependency has been removed.", :green
      end
    end

    class Main < Base
      option :quiet, type: :boolean, aliases: :q
      desc "rescan", "Find new dependencies."
      def rescan
        die_on_error {
          spinner {
            DependencyManager.sync_with_bundler
          }
        }

        action_items
      end
      default_task :rescan

      desc "approve DEPENDENCY_NAME", "Approve a dependency by name."
      def approve(name)
        die_on_error {
          DependencyManager.approve!(name)
        }

        say "The #{name} dependency has been approved!", :green
      end

      desc "license LICENSE DEPENDENCY_NAME", "Update a dependency's license."
      def license(license, name)
        die_on_error {
          DependencyManager.license!(name, license)
        }

        say "The #{name} dependency has been marked as using #{license} license!", :green
      end

      desc "move", "Move dependency.* files from root directory to doc/."
      def move
        Configuration.move!
        say "Congratulations, you have cleaned up your root directory!'", :green
      end

      desc "action_items", "List unapproved dependencies"
      def action_items
        unapproved = Dependency.unapproved

        if unapproved.empty?
          say "All gems are approved for use", :green
        else
          say "Dependencies that need approval:", :red
          say TextReport.new(unapproved)
          exit 1
        end
      end

      subcommand "dependencies", Dependencies, "manage non-Bundler dependencies"

      private

      def spinner
        if options[:quiet]
          yield
        else
          begin
            thread = Thread.new {
              wheel = '\|/-'
              i = 0
              while true do
                print "\r ---------- #{wheel[i]} ----------"
                i = (i + 1) % 4
              end
            }
            yield
          ensure
            if thread
              thread.kill
              puts "\r" + " "*24
            end
          end
        end
      end
    end
  end
end
