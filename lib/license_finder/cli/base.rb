module LicenseFinder
  module CLI
    class Base < Thor
      class_option :decisions_file, desc: "Where to save the decisions. Defaults to doc/dependency_decisions.yml."

      def self.auditable
        method_option :who, desc: "The person making this decision"
        method_option :why, desc: "The reason for making this decision"
      end

      no_commands do
        def decisions
          @decisions ||= Decisions.saved!(config.decisions_file)
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

      def config
        @config ||= Configuration.with_optional_saved_config(options)
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
  end
end

