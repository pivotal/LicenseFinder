module LicenseFinder
  module CLI
    module MakesDecisions
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        def auditable
          method_option :who, desc: "The person making this decision"
          method_option :why, desc: "The reason for making this decision"
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
        # decisions = Decisions.saved! # is part of Base
        yield
        decisions.save!(config.decisions_file)
      end

      def modify_each(*things)
        modifying { things.each { |thing| yield thing } }
        things
      end
    end
  end
end

