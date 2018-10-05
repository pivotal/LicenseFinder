# frozen_string_literal: true

module LicenseFinder
  module CLI
    module Rootcommand
      # Helper to auto-generate the documentation for a group of commands
      def subcommand(namespace, klass, namespace_description)
        description = "#{namespace} [#{(klass.tasks.keys - ['help']).join('|')}]"
        desc description, "#{namespace_description} - see `license_finder #{namespace} help` for more information"
        super namespace, klass
      end
    end

    # Thor fix for `license_finder <subcommand> help <action>`
    module Subcommand
      # Hack to override the help message produced by Thor.
      # https://github.com/wycats/thor/issues/261#issuecomment-16880836
      def banner(command, _namespace = nil, _subcommand = nil)
        "#{basename} #{underscore_name(name)} #{command.usage}"
      end

      protected

      def underscore_name(name)
        underscored = name.split('::').last
        underscored.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        underscored.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        underscored.tr!('-', '_')
        underscored.downcase
      end
    end
  end
end
