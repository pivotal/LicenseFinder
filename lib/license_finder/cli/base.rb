module LicenseFinder
  module CLI
    class Base < Thor
      class_option :decisions_file, desc: "Where decisions are saved. Defaults to doc/dependency_decisions.yml."

      no_commands do
        def decisions
          @decisions ||= Decisions.saved!(config.decisions_file)
        end
      end

      private

      def config
        @config ||= Configuration.with_optional_saved_config(options)
      end
    end
  end
end

