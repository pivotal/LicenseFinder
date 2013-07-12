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
      option :approve, type: :boolean, aliases: :a
      desc "add LICENSE DEPENDENCY_NAME [VERSION] [--approve]", "Add a dependency that is not managed by Bundler"
      def add(license, name, version = nil)
        die_on_error {
          DependencyManager.create_non_bundler(license, name, version)
          DependencyManager.approve!(name) if options[:approve]
        }
        if options[:approve]
          say "The #{name} dependency has been added and approved!", :green
        else
          say "The #{name} dependency has been added!", :green
        end
      end

      desc "remove DEPENDENCY_NAME", "Remove a dependency that is not managed by Bundler"
      def remove(name)
        die_on_error {
          DependencyManager.destroy_non_bundler(name)
        }

        say "The #{name} dependency has been removed.", :green
      end
    end

    class Whitelist < Base
      desc "list", "List all the whitelisted licenses"
      def list
        whitelist = LicenseFinder.config.whitelist

        say "Whitelisted Licenses:", :blue
        whitelist.each do |license|
          say license
        end
      end

      desc "add", "Add a license to the whitelist"
      def add(license)
        die_on_error {
          LicenseFinder.config.whitelist.push(license)
          LicenseFinder.config.save
        }
        say "Added #{license} to the license whitelist"
      end

      desc "remove", "Remove a license from the whitelist"
      def remove(license)
        die_on_error {
          LicenseFinder.config.whitelist.delete(license)
          LicenseFinder.config.save
        }
        say "Removed #{license} from the license whitelist"
      end
    end

    class IgnoredBundlerGroups < Base
      desc "list", "List all the ignored bundler groups"
      def list
        ignored = LicenseFinder.config.ignore_groups

        say "Ignored Bundler Groups:", :blue
        ignored.each do |group|
          say group
        end
      end

      desc "add", "Add a bundler group to be ignored"
      def add(group)
        die_on_error {
          LicenseFinder.config.ignore_groups.push(group)
          LicenseFinder.config.save
        }
        say "Added #{group} to the ignored bundler groups"
      end

      desc "remove", "Remove a bundler group from the ignored bundler groups"
      def remove(group)
        die_on_error {
          LicenseFinder.config.ignore_groups.delete(group)
          LicenseFinder.config.save
        }
        say "Removed #{group} from the ignored bundler groups"
      end
    end

    class Main < Base
      option :quiet, type: :boolean, desc: "silences loading output"
      desc "rescan", "Find new dependencies. (Default action)"
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
      subcommand "ignored_bundler_groups", IgnoredBundlerGroups, "manage ignored bundler groups"
      subcommand "whitelist", Whitelist, "manage whitelisted licenses"

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
