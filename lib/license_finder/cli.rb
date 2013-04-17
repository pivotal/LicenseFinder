require 'thor'

module LicenseFinder
  class CLI < Thor
    def self.log(*messages)
      puts messages
    end

    no_commands do
      def log(*messages)
        self.class.log(*messages)
      end

      def spinner
        if options[:quiet]
          yield
        else
          thread = Thread.new() {
            wheel = '\|/-'
            i = 0
            while true do
              print "\r ---------- #{wheel[i]} ----------"
              i = (i + 1) % 4
            end
          }
          yield
          thread.kill
        end
      end
    end

    class_option :quiet, type: :boolean, aliases: :q

    desc "rescan", "Find new dependencies."
    def rescan
      spinner {
        BundleSyncer.sync!
        generate_reports
      }

      unapproved = Dependency.unapproved

      log "\r" + " "*24
      if unapproved.count == 0
        log "All gems are approved for use"
      else
        log "Dependencies that need approval:"
        log TextReport.new(unapproved)
        exit 1
      end
    end
    default_task :rescan

    desc "approve DEPENDENCY_NAME", "Approve a dependency by name."
    def approve(name)
      dependency = Dependency.first(name: name)
      dependency.approve!

      log "The #{dependency.name} has been approved!\n\n"

      generate_reports
    end

    desc "license LICENSE DEPENDENCY_NAME", "Update a dependency's license."
    def license(license, name)
      dependency = Dependency.first(name: name)
      dependency.set_license_manually license

      log "The #{name} has been marked as using #{license} license!\n\n"

      generate_reports
    end

    desc "move", "Move dependency.* files from root directory to doc/."
    def move
      `sed '$d' < config/license_finder.yml > tmp34567.txt`
      `mv tmp34567.txt config/license_finder.yml`
      `echo "dependencies_file_dir: './doc/'" >> config/license_finder.yml`
      `mkdir -p doc`
      `mv dependencies.* doc/`
      log "Congratulations, you have cleaned up your root directory!'"
    end

    private

    def generate_reports
      Reporter.write_reports
    end
  end
end
