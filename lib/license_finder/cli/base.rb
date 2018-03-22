require 'thor'

module LicenseFinder
  module CLI
    class Base < Thor
      class_option :project_path,
                   desc: 'Path to the project. Defaults to current working directory.'
      class_option :decisions_file,
                   desc: 'Where decisions are saved. Defaults to doc/dependency_decisions.yml.'
      class_option :log_directory,
                   desc: 'Where logs are saved. Defaults to ./lf_logs/$PROJECT/prepare_$PACKAGE_MANAGER.log'

      no_commands do
        def decisions
          @decisions ||= DecisionsFactory.decisions(config.decisions_file_path)
        end

        def config
          @config ||= Configuration.with_optional_saved_config(license_finder_config)
        end
      end

      private

      def fail(message)
        say(message) && exit(1)
      end

      def license_finder_config
        extract_options(
          :project_path,
          :decisions_file,
          :go_full_version,
          :gradle_command,
          :gradle_include_groups,
          :maven_include_groups,
          :maven_options,
          :pip_requirements_path,
          :rebar_command,
          :rebar_deps_dir,
          :mix_command,
          :mix_deps_dir,
          :save,
          :prepare,
          :prepare_no_fail,
          :log_directory,
          :format,
          :columns,
          :aggregate_paths,
          :recursive,
          :sbt_include_groups
        ).merge(
          logger: logger_mode
        )
      end

      def logger_mode
        quiet = LicenseFinder::Logger::MODE_QUIET
        debug = LicenseFinder::Logger::MODE_DEBUG
        info = LicenseFinder::Logger::MODE_INFO
        mode = extract_options(quiet, debug)
        if mode[quiet]
          quiet
        elsif mode[debug]
          debug
        else
          info
        end
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
        raise ArgumentError, 'wrong number of arguments (0 for 1+)', caller unless things.any?
      end

      def extract_options(*keys)
        result = {}
        keys.each do |key|
          result[key.to_sym] = options[key.to_s] if options.key? key.to_s
        end
        result
      end
    end
  end
end
