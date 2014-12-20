require 'thor'

module LicenseFinder
  module CLI
    class Base < Thor
      def self.subcommand(namespace, klass, namespace_description)
        description = "#{namespace} [#{(klass.tasks.keys - ["help"]).join("|")}]"
        desc description, "#{namespace_description} - see `license_finder #{namespace} help` for more information"
        super namespace, klass
      end

      class_option :who, desc: "The person making this decision"
      class_option :why, desc: "The reason for making this decision"

      no_commands do
        def decisions
          @decisions ||= Decisions.saved!
        end
      end

      private

      def say_each(coll)
        if coll.any?
          coll.each do |item|
            say(block_given? ? yield(item) : item)
          end
        else
          say '(none)'
        end
      end

      def txn
        @txn ||= {
          who: options[:who],
          why: options[:why],
          when: Time.now.getutc
        }
      end

      def modifying
        yield
        decisions.save!
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

    class Whitelist < Subcommand
      desc "list", "List all the whitelisted licenses"
      def list
        say "Whitelisted Licenses:", :blue
        say_each(decisions.whitelisted) { |license| license.name }
      end

      desc "add LICENSE...", "Add one or more licenses to the whitelist"
      def add(license, *other_licenses)
        licenses = other_licenses.unshift license
        modifying {
          licenses.each do |license|
            decisions.whitelist(license, txn)
          end
        }
        say "Added #{licenses.join(", ")} to the license whitelist"
      end

      desc "remove LICENSE...", "Remove one or more licenses from the whitelist"
      def remove(license, *other_licenses)
        licenses = other_licenses.unshift license
        modifying {
          licenses.each do |license|
            decisions.unwhitelist(license, txn)
          end
        }
        say "Removed #{licenses.join(", ")} from the license whitelist"
      end
    end

    class ProjectName < Subcommand
      desc "show", "Show the project name"
      def show
        say "Project Name:", :blue
        say decisions.project_name
      end

      desc "add NAME", "Set the project name"
      def add(name)
        modifying { decisions.name_project(name, txn) }

        say "Set the project name to #{name}", :green
      end

      desc "remove", "Remove the project name"
      def remove
        modifying { decisions.unname_project(txn) }

        say "Removed the project name"
      end
    end

    class IgnoredGroups < Subcommand
      desc "list", "List all the ignored groups"
      def list
        say "Ignored Groups:", :blue
        say_each(decisions.ignored_groups)
      end

      desc "add GROUP", "Add a group to be ignored"
      def add(group)
        modifying { decisions.ignore_group(group, txn) }

        say "Added #{group} to the ignored groups"
      end

      desc "remove GROUP", "Remove a group from the ignored groups"
      def remove(group)
        modifying { decisions.heed_group(group, txn) }

        say "Removed #{group} from the ignored groups"
      end
    end

    class IgnoredDependencies < Subcommand
      desc "list", "List all the ignored dependencies"
      def list
        say "Ignored Dependencies:", :blue
        say_each(decisions.ignored)
      end

      desc "add DEPENDENCY", "Add a dependency to be ignored"
      def add(dep)
        modifying { decisions.ignore(dep, txn) }

        say "Added #{dep} to the ignored dependencies"
      end

      desc "remove DEPENDENCY", "Remove a dependency from the ignored dependencies"
      def remove(dep)
        modifying { decisions.heed(dep, txn) }

        say "Removed #{dep} from the ignored dependencies"
      end
    end

    class Main < Base
      FORMATS = {
        'text' => TextReport,
        'detailed_text' => DetailedTextReport,
        'html' => HtmlReport,
        'markdown' => MarkdownReport
      }

      method_option :quiet, type: :boolean, desc: "silences progress report"
      method_option :debug, type: :boolean, desc: "emit detailed info about what LicenseFinder is doing"
      method_option :format, desc: "The desired output format. Pick from: #{FORMATS.keys.inspect}", default: 'text'
      desc "action_items", "List unapproved dependencies (the default action for `license_finder`)"
      def action_items
        unapproved = decision_applier.unapproved

        if unapproved.empty?
          say "All dependencies are approved for use", :green
        else
          say "Dependencies that need approval:", :red
          say report_of(unapproved)
          exit 1
        end
      end

      default_task :action_items

      desc "approve DEPENDENCY_NAME...", "Approve one or more dependencies by name"
      def approve(name, *other_names)
        names = other_names.unshift name
        modifying { names.each { |name| decisions.approve(name, txn) } }

        say "The #{names.join(", ")} dependency has been approved!", :green
      end

      desc "license LICENSE DEPENDENCY_NAME", "Update a dependency's license"
      def license(license, name)
        modifying { decisions.license(name, license, txn) }

        say "The #{name} dependency has been marked as using #{license} license!", :green
      end

      method_option :format, desc: "The desired output format. Pick from: #{FORMATS.keys.inspect}", default: 'text'
      desc "report", "Print a report of the project's dependencies to stdout"
      def report
        dependencies = decision_applier(Logger.new(quiet: true))
        say report_of(dependencies.acknowledged)
      end

      subcommand "dependencies", Dependencies, "Manually manage dependencies that your package managers are not aware of"
      subcommand "ignored_groups", IgnoredGroups, "Manage ignored groups"
      subcommand "ignored_dependencies", IgnoredDependencies, "Manage ignored dependencies"
      subcommand "whitelist", Whitelist, "Manage whitelisted licenses"
      subcommand "project_name", ProjectName, "Manage the project name, for display in reports"

      private

      # The core of the system. The saved decisions are applied to the current
      # packages.
      def decision_applier(logger = Logger.new(options))
        @decision_applier ||= DecisionApplier.new(
          decisions: decisions,
          packages: PackageManager.current_packages(logger)
        )
      end

      def report_of(content)
        report = FORMATS[options[:format]]
        if !report
          say "Format #{options[:format]} not recognized. Valid formats #{FORMATS.keys.inspect}", :red
          exit 1
        end
        report.of(content, decisions.project_name)
      end
    end
  end
end
