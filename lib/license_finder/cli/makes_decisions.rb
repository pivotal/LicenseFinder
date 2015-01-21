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

      def txn
        @txn ||= {
          who: options[:who],
          why: options[:why],
          when: Time.now.getutc
        }
      end

      def modifying(&block)
        license_finder.modifying(&block)
      end
    end
  end
end
