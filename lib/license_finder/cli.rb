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

      def sync_with_package_managers options={}
        die_on_error {
          logger = LicenseFinder::Logger.new options
          DependencyManager.new(logger: logger).sync_with_package_managers
        }
      end

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
      method_option :approver, desc: "The person granting the approval"
      method_option :message, desc: "The reason for the approval"
      desc "add LICENSE DEPENDENCY_NAME [VERSION] [--approve] [--approver APPROVER_NAME] [--message APPROVAL_MESSAGE]", "Add a dependency that is not managed by a package manager, optionally storing who approved the dependency and why"
      def add(license, name, version = nil)
        die_on_error {
          DependencyManager.new.tap do |dependency_manager|
            dependency_manager.manually_add(license, name, version)
            dependency_manager.approve!(name, options[:approver], options[:message]) if options[:approve]
          end
        }
        if options[:approve]
          say "The #{name} dependency has been added and approved!", :green
        else
          say "The #{name} dependency has been added!", :green
        end
      end

      desc "remove DEPENDENCY_NAME", "Remove a dependency that is not managed by a package manager"
      def remove(name)
        die_on_error {
          DependencyManager.new.manually_remove(name)
        }

        say "The #{name} dependency has been removed.", :green
      end

      desc "list", "List manually added dependencies"
      def list
        packages = Decisions.saved!.packages

        say "Manually Added Dependencies:", :blue
        if packages.any?
          packages.each do |package|
            say package.name
          end
        else
          say '(none)'
        end
      end
    end

    class ConfigSubcommand < Subcommand
      private

      def modifying
        die_on_error {
          yield

          LicenseFinder.config.save
          sync_with_package_managers
        }
      end
    end

    class Whitelist < ConfigSubcommand
      desc "list", "List all the whitelisted licenses"
      def list
        whitelist = Decisions.saved!.whitelisted

        say "Whitelisted Licenses:", :blue
        whitelist.each do |license|
          say license.name
        end
      end

      desc "add LICENSE...", "Add one or more licenses to the whitelist"
      def add(license, *other_licenses)
        licenses = other_licenses.unshift license
        decisions = Decisions.saved!
        modifying {
          licenses.each do |license|
            LicenseFinder.config.whitelist.push(license)
            decisions.whitelist(license)
          end
        }
        decisions.save!
        say "Added #{licenses.join(", ")} to the license whitelist"
      end

      desc "remove LICENSE...", "Remove one or more licenses from the whitelist"
      def remove(license, *other_licenses)
        licenses = other_licenses.unshift license
        decisions = Decisions.saved!
        modifying {
          licenses.each do |license|
            LicenseFinder.config.whitelist.delete(license)
            decisions.unwhitelist(license)
          end
        }
        decisions.save!
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
        ignored = Decisions.saved!.ignored_groups

        say "Ignored Bundler Groups:", :blue
        ignored.each do |group|
          say group
        end
      end

      desc "add GROUP", "Add a bundler group to be ignored"
      def add(group)
        modifying {
          LicenseFinder.config.ignore_groups.push(group)
          Decisions.saved!.ignore_group(group).save!
        }
        say "Added #{group} to the ignored bundler groups"
      end

      desc "remove GROUP", "Remove a bundler group from the ignored bundler groups"
      def remove(group)
        modifying {
          LicenseFinder.config.ignore_groups.delete(group)
          Decisions.saved!.heed_group(group).save!
        }
        say "Removed #{group} from the ignored bundler groups"
      end
    end

    class IgnoredDependencies < ConfigSubcommand
      desc "list", "List all the ignored dependencies"
      def list
        ignored = LicenseFinder.config.ignore_dependencies
        ignored = Decisions.saved!.ignored

        say "Ignored Dependencies:", :blue
        if ignored.any?
          ignored.each do |name|
            say name
          end
        else
          say '(none)'
        end
      end

      desc "add DEPENDENCY", "Add a dependency to be ignored"
      def add(dep)
        modifying {
          LicenseFinder.config.ignore_dependencies.push(dep)
          Decisions.saved!.ignore(dep).save!
        }
        say "Added #{dep} to the ignored dependencies"
      end

      desc "remove DEPENDENCY", "Remove a dependency from the ignored dependencies"
      def remove(dep)
        modifying {
          LicenseFinder.config.ignore_dependencies.delete(dep)
          Decisions.saved!.heed(dep).save!
        }
        say "Removed #{dep} from the ignored dependencies"
      end
    end

    class Main < Base
      desc "action_items", "List unapproved dependencies"
      def action_items
        unapproved = DependencyManager.new.unapproved

        if unapproved.empty?
          say "All dependencies are approved for use", :green
        else
          say "Dependencies that need approval:", :red
          say TextReport.new(unapproved)
          exit 1
        end
      end

      default_task :action_items

      method_option :approver, desc: "The person granting the approval"
      method_option :message, desc: "The reason for the approval"
      desc "approve DEPENDENCY_NAME... [--approver APPROVER_NAME] [--message APPROVAL_MESSAGE]", "Approve one or more dependencies by name, optionally storing who approved the dependency and why"
      def approve(name, *other_names)
        names = other_names.unshift name
        die_on_error {
          names.each { |name| DependencyManager.new.approve!(name, options[:approver], options[:message]) }
        }

        say "The #{names.join(", ")} dependency has been approved!", :green
      end

      desc "license LICENSE DEPENDENCY_NAME", "Update a dependency's license"
      def license(license, name)
        die_on_error {
          DependencyManager.new.license!(name, license)
        }

        say "The #{name} dependency has been marked as using #{license} license!", :green
      end

      desc "move", "Move dependency.* files from root directory to doc/"
      def move
        Configuration.move!
        say "Congratulations, you have cleaned up your root directory!'", :green
      end

      subcommand "dependencies", Dependencies, "Manually manage dependencies that your package managers are not aware of"
      subcommand "ignored_bundler_groups", IgnoredBundlerGroups, "Manage ignored Bundler groups"
      subcommand "ignored_dependencies", IgnoredDependencies, "Manage ignored dependencies"
      subcommand "whitelist", Whitelist, "Manage whitelisted licenses"
      subcommand "project_name", ProjectName, "Manage the project name"

    end
  end
end
