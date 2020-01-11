# frozen_string_literal: true

module LicenseFinder
  module CLI
    module MakesDecisions
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        def auditable
          method_option :who, desc: 'The person making this decision'
          method_option :why, desc: 'The reason for making this decision'
        end

        def approvable
          method_option :version, desc: 'The version that will be approved'
        end
      end

      private

      def txn
        @txn ||= {
          who: options[:who],
          why: options[:why],
          versions: options[:version] ? [options[:version]] : [],
          when: Time.now.getutc
        }
      end

      def modifying
        yield
        decisions.save!(config.decisions_file_path)
      end
    end
  end
end
