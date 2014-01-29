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

    # Thor fix for `license_finder <subcommand> help <action>`
    class Subcommand < Base
      # Hack to override the help message produced by Thor.
      # https://github.com/wycats/thor/issues/261#issuecomment-16880836
      def self.banner(command, namespace = nil, subcommand = nil)
        "#{basename} #{underscore_name(name)} #{command.usage}"
      end

      protected

      def self.underscore_name(name)
        underscored = name.split("::").last
        underscored.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        underscored.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        underscored.tr!("-", "_")
        underscored.downcase
      end
    end

    class Dependencies < Subcommand
      method_option :approve, type: :boolean, desc: "Approve the added dependency"
      desc "Add LICENSE DEPENDENCY_NAME [VERSION] [--approve]", "Add a dependency that is not managed by Bundler, NPM, etc"
      def add(license, name, version = nil)
        die_on_error {
          DependencyManager.create_manually_managed(license, name, version)
          DependencyManager.approve!(name) if options[:approve]
        }
        if options[:approve]
          say "The #{name} dependency has been added and approved!", :green
        else
          say "The #{name} dependency has been added!", :green
        end
      end

      desc "Remove DEPENDENCY_NAME", "Remove a dependency that is not managed by Bundler, NPM, etc"
      def remove(name)
        die_on_error {
          DependencyManager.destroy_manually_managed(name)
        }

        say "The #{name} dependency has been removed.", :green
      end
    end

    class ConfigSubcommand < Subcommand
      private

      def modifying
        die_on_error {
          yield

          LicenseFinder.config.save
          Reporter.write_reports
        }
      end
    end

    class Whitelist < ConfigSubcommand
      desc "list", "List all the whitelisted licenses"
      def list
        whitelist = LicenseFinder.config.whitelist

        say "Whitelisted Licenses:", :blue
        whitelist.each do |license|
          say license
        end
      end

      desc "add LICENSE", "Add one ore more licenses to the whitelist"
      def add(*licenses)
        modifying {
          licenses.each do |license|
            LicenseFinder.config.whitelist.push(license)
          end
        }
        say "Added #{licenses.join(", ")} to the license whitelist"
      end

      desc "remove LICENSE", "Remove one ore more licenses from the whitelist"
      def remove(*licenses)
        modifying {
          licenses.each do |license|
            LicenseFinder.config.whitelist.delete(license)
          end
        }
        say "Removed #{licenses.join(", ")} from the license whitelist"
      end
    end

    class ProjectName < ConfigSubcommand
      desc "set NAME", "Set the project name"
      def set(name)
        modifying {
          LicenseFinder.config.project_name = name
        }
        say "Set the project name to #{name}", :green
      end
    end

    class IgnoredBundlerGroups < ConfigSubcommand
      desc "list", "List all the ignored bundler groups"
      def list
        ignored = LicenseFinder.config.ignore_groups

        say "Ignored Bundler Groups:", :blue
        ignored.each do |group|
          say group
        end
      end

      desc "add GROUP", "Add a bundler group to be ignored"
      def add(group)
        modifying {
          LicenseFinder.config.ignore_groups.push(group)
        }
        say "Added #{group} to the ignored bundler groups"
      end

      desc "remove GROUP", "Remove a bundler group from the ignored bundler groups"
      def remove(group)
        modifying {
          LicenseFinder.config.ignore_groups.delete(group)
        }
        say "Removed #{group} from the ignored bundler groups"
      end
    end

    class Main < Base
      method_option :quiet, type: :boolean, desc: "silences loading output"
      desc "rescan", "Find new dependencies. (Default action)"
      def rescan
        die_on_error {
          spinner {
            DependencyManager.sync_with_package_managers
          }
        }

        action_items
      end
      default_task :rescan

      desc "approve DEPENDENCY_NAME", "Approve one ore more dependencies by name"
      def approve(*names)
        die_on_error {
          names.each { |name| DependencyManager.approve!(name) }
        }

        say "The #{names.join(", ")} dependency has been approved!", :green
      end

      desc "license LICENSE DEPENDENCY_NAME", "Update a dependency's license"
      def license(license, name)
        die_on_error {
          DependencyManager.license!(name, license)
        }

        say "The #{name} dependency has been marked as using #{license} license!", :green
      end

      desc "move", "Move dependency.* files from root directory to doc/"
      def move
        Configuration.move!
        say "Congratulations, you have cleaned up your root directory!'", :green
      end

      desc "action_items", "List unapproved dependencies"
      def action_items
        unapproved = Dependency.unapproved

        if unapproved.empty?
          say "All dependencies are approved for use", :green
        else
          say "Dependencies that need approval:", :red
          say TextReport.new(unapproved)
          exit 1
        end
      end

      subcommand "dependencies", Dependencies, "Manually manage dependencies outside of Bundler, NPM, pip, etc"
      subcommand "ignored_bundler_groups", IgnoredBundlerGroups, "Manage ignored bundler groups"
      subcommand "whitelist", Whitelist, "Manage whitelisted licenses"
      subcommand "project_name", ProjectName, "Manage the project name"

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
