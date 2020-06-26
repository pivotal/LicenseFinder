# frozen_string_literal: true

module LicenseFinder
  module CLI
    class InheritedDecisions < Base
      extend Subcommand
      include MakesDecisions

      desc 'list', 'List all the inherited decision files'
      def list
        say 'Inherited Decision Files:', :blue
        say_each(decisions.inherited_decisions)
      end

      auditable
      desc 'add DECISION_FILE...', 'Add one or more decision files to the inherited decisions'
      def add(*decision_files)
        assert_some decision_files
        modifying { decision_files.each { |filepath| decisions.inherit_from(filepath) } }
        say "Added #{decision_files.join(', ')} to the inherited decisions"
      end

      auditable
      desc 'add_with_auth URL AUTH_TYPE TOKEN_OR_ENV', 'Add a remote decision file that needs authentication'
      def add_with_auth(*params)
        url, auth_type, token_or_env = params
        auth_info = { 'url' => url, 'authorization' => "#{auth_type} #{token_or_env}" }
        modifying { decisions.add_decision [:inherit_from, auth_info] }
        say "Added #{url} to the inherited decisions"
      end

      auditable
      desc 'remove DECISION_FILE...', 'Remove one or more decision files from the inherited decisions'
      def remove(*decision_files)
        assert_some decision_files
        modifying { decision_files.each { |filepath| decisions.remove_inheritance(filepath) } }
        say "Removed #{decision_files.join(', ')} from the inherited decisions"
      end

      auditable
      desc 'remove_with_auth URL AUTH_TYPE TOKEN_OR_ENV', 'Add a remote decision file that needs authentication'
      def remove_with_auth(*params)
        url, auth_type, token_or_env = params
        auth_info = { 'url' => url, 'authorization' => "#{auth_type} #{token_or_env}" }
        modifying { decisions.remove_inheritance(auth_info) }
        say "Removed #{url} from the inherited decisions"
      end
    end
  end
end
