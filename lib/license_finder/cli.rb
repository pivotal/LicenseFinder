require 'thor'

module LicenseFinder
  module CLI
    class Base < Thor
      def self.subcommand(namespace, klass, namespace_description)
        description = "#{namespace} [#{(klass.tasks.keys - ["help"]).join("|")}]"
        desc description, "#{namespace_description} - see `license_finder #{namespace} help` for more information"
        super namespace, klass
      end

      no_commands do
        def decisions
          @decisions ||= Decisions.saved!
        end
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

    class DecisionSubcommand < Subcommand
      private

      def modifying
        die_on_error {
          yield decisions
          decisions.save!
        }
      end
    end

    class ConfigSubcommand < Subcommand
      private

      def modifying
        die_on_error {
          yield

          LicenseFinder.config.save
        }
      end
    end

    class Dependencies < DecisionSubcommand
      method_option :approve, type: :boolean, desc: "Approve the added dependency"
      method_option :approver, desc: "The person granting the approval"
      method_option :message, desc: "The reason for the approval"
      desc "add LICENSE DEPENDENCY_NAME [VERSION] [--approve] [--approver APPROVER_NAME] [--message APPROVAL_MESSAGE]", "Add a dependency that is not managed by a package manager, optionally storing who approved the dependency and why"
      def add(license, name, version = nil)
        modifying { |decisions|
          txn = {
            who: options[:approver],
            why: options[:message],
            when: Time.now.getutc
          }
          decisions.
            add_package(name, version).
            license(name, license)
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
        modifying { |decisions|
          decisions.remove_package(name)
        }

        say "The #{name} dependency has been removed.", :green
      end

      desc "list", "List manually added dependencies"
      def list
        packages = decisions.packages

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

    class Whitelist < DecisionSubcommand
      desc "list", "List all the whitelisted licenses"
      def list
        whitelist = decisions.whitelisted

        say "Whitelisted Licenses:", :blue
        whitelist.each do |license|
          say license.name
        end
      end

      desc "add LICENSE...", "Add one or more licenses to the whitelist"
      def add(license, *other_licenses)
        licenses = other_licenses.unshift license
        modifying { |decisions|
          licenses.each do |license|
            decisions.whitelist(license)
          end
        }
        say "Added #{licenses.join(", ")} to the license whitelist"
      end

      desc "remove LICENSE...", "Remove one or more licenses from the whitelist"
      def remove(license, *other_licenses)
        licenses = other_licenses.unshift license
        modifying { |decisions|
          licenses.each do |license|
            decisions.unwhitelist(license)
          end
        }
        say "Removed #{licenses.join(", ")} from the license whitelist"
      end
    end

    class ProjectName < ConfigSubcommand
      desc "set NAME", "Set the project name"
      def set(name)
        modifying { |decisions|
          LicenseFinder.config.project_name = name
        }
        say "Set the project name to #{name}", :green
      end
    end

    class IgnoredBundlerGroups < DecisionSubcommand
      desc "list", "List all the ignored bundler groups"
      def list
        ignored = decisions.ignored_groups

        say "Ignored Bundler Groups:", :blue
        ignored.each do |group|
          say group
        end
      end

      desc "add GROUP", "Add a bundler group to be ignored"
      def add(group)
        modifying { |decisions|
          decisions.ignore_group(group)
        }
        say "Added #{group} to the ignored bundler groups"
      end

      desc "remove GROUP", "Remove a bundler group from the ignored bundler groups"
      def remove(group)
        modifying { |decisions|
          decisions.heed_group(group)
        }
        say "Removed #{group} from the ignored bundler groups"
      end
    end

    class IgnoredDependencies < DecisionSubcommand
      desc "list", "List all the ignored dependencies"
      def list
        ignored = decisions.ignored

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
        modifying { |decisions|
          decisions.ignore(dep)
        }
        say "Added #{dep} to the ignored dependencies"
      end

      desc "remove DEPENDENCY", "Remove a dependency from the ignored dependencies"
      def remove(dep)
        modifying { |decisions|
          decisions.heed(dep)
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

      FORMATS = {
        'text' => TextReport,
        'detailed_text' => DetailedTextReport,
        'html' => HtmlReport,
        'markdown' => MarkdownReport
      }

      method_option :format, desc: "The desired output format: #{FORMATS.keys.inspect}", default: 'text'
      desc "report", "Print a report of the project's dependencies to stdout"
      def report
        formatter = FORMATS[options[:format]]
        if !formatter
          say "Format #{options[:format]} not recognized. Valid formats #{FORMATS.keys.inspect}", :red
          exit 1
        end
        say formatter.of(DependencyManager.new.acknowledged)
      end

      subcommand "dependencies", Dependencies, "Manually manage dependencies that your package managers are not aware of"
      subcommand "ignored_bundler_groups", IgnoredBundlerGroups, "Manage ignored Bundler groups"
      subcommand "ignored_dependencies", IgnoredDependencies, "Manage ignored dependencies"
      subcommand "whitelist", Whitelist, "Manage whitelisted licenses"
      subcommand "project_name", ProjectName, "Manage the project name"

    end
  end
end
