require 'thor'

module LicenseFinder
  class CLIBase < Thor
    def self.subcommand(namespace, klass, namespace_description)
      description = "#{namespace} [#{(klass.tasks.keys - ["help"]).join("|")}]"
      desc description, "#{namespace_description} - see `license_finder #{namespace} help` for more information"
      super namespace, klass
    end

    private

    def modifying
      yield
      Reporter.write_reports
    rescue LicenseFinder::Error => e
      say e.message, :red
      exit 1
    end
  end

  class CLI < CLIBase
    option :quiet, type: :boolean, aliases: :q
    desc "rescan", "Find new dependencies."
    def rescan
      modifying {
        spinner {
          BundleSyncer.sync!
        }
      }

      action_items
    end
    default_task :rescan

    desc "approve DEPENDENCY_NAME", "Approve a dependency by name."
    def approve(name)
      modifying {
        dependency = Dependency.first(name: name)
        dependency.approve!
      }

      say "The #{name} dependency has been approved!", :green
    end

    desc "license LICENSE DEPENDENCY_NAME", "Update a dependency's license."
    def license(license, name)
      modifying {
        dependency = Dependency.first(name: name)
        dependency.set_license_manually license
      }

      say "The #{name} dependency has been marked as using #{license} license!", :green
    end

    desc "move", "Move dependency.* files from root directory to doc/."
    def move
      config = Configuration.config_hash('dependencies_file_dir' => './doc/')
      File.open(Configuration.config_file_path, 'w') do |f|
        f.write YAML.dump(config)
      end

      FileUtils.mkdir_p("doc")
      FileUtils.mv(Dir["dependencies.*"], "doc")
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

    class Dependencies < CLIBase
      desc "add LICENSE DEPENDENCY_NAME [VERSION]", "Add a dependency that is not managed by Bundler"
      def add(license, name, version = nil)
        modifying {
          Dependency.create_non_bundler(license, name, version)
        }

        say "The #{name} dependency has been added!", :green
      end

      desc "remove DEPENDENCY_NAME", "Remove a dependency that is not managed by Bundler"
      def remove(name)
        modifying {
          Dependency.destroy_non_bundler(name)
        }

        say "The #{name} dependency has been removed.", :green
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
