require 'thor'

module LicenseFinder
  module CLI
    class Base < Thor
      class_option :decisions_file, desc: "Where decisions are saved. Defaults to doc/dependency_decisions.yml."

      no_commands do
        def decisions
          license_finder.decisions
        end
      end

      private

      def license_finder
        @lf ||= LicenseFinder::Core.new(license_finder_config)
      end

      def license_finder_config
        result = { logger: logger_config }
        result[:decisions_file] = options["decisions_file"] if options.has_key? "decisions_file"
        result[:gradle_command] = options["gradle_command"] if options.has_key? "gradle_command"
        result
      end

      def logger_config
        @logger_config ||= logger_config_from_options
      end

      def logger_config_from_options
        result = {}
        result[:quiet] = options["quiet"] if options.has_key? "quiet"
        result[:debug] = options["debug"] if options.has_key? "debug"
        result
      end

      def say_each(coll)
        if coll.any?
          coll.each do |item|
            say(block_given? ? yield(item) : item)
          end
        else
          say '(none)'
        end
      end

      def assert_some(things)
        unless things.any?
          raise ArgumentError, "wrong number of arguments (0 for 1+)", caller
        end
      end
    end
  end
end

