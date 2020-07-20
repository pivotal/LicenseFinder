# frozen_string_literal: true

require 'rubygems'

class InvalidErlangmkPackageError < ArgumentError
end

# NOTE:
# Command:
#   make QUERY='name fetch_method repo version absolute_path' query-deps
# Output:
# make[1]: Entering directory '/home/lbakken/development/rabbitmq/umbrella/deps/credentials_obfuscation'
# make[1]: Leaving directory '/home/lbakken/development/rabbitmq/umbrella/deps/credentials_obfuscation'
# rabbit_common: rabbitmq_codegen git_rmq https://github.com/rabbitmq/rabbitmq-codegen master /home/lbakken/development/rabbitmq/umbrella/deps/rabbitmq_codegen
# rabbit_common: lager hex https://hex.pm/packages/lager 3.8.0 /home/lbakken/development/rabbitmq/umbrella/deps/lager
# rabbit_common: jsx hex https://hex.pm/packages/jsx 2.9.0 /home/lbakken/development/rabbitmq/umbrella/deps/jsx
# rabbit_common: ranch hex https://hex.pm/packages/ranch 1.7.1 /home/lbakken/development/rabbitmq/umbrella/deps/ranch
# rabbit_common: recon hex https://hex.pm/packages/recon 2.5.1 /home/lbakken/development/rabbitmq/umbrella/deps/recon
# rabbit_common: credentials_obfuscation hex https://hex.pm/packages/credentials_obfuscation 2.0.0 /home/lbakken/development/rabbitmq/umbrella/deps/credentials_obfuscation
# lager: goldrush git https://github.com/DeadZen/goldrush.git 0.1.9 /home/lbakken/development/rabbitmq/umbrella/deps/goldrush

module LicenseFinder
  class ErlangmkPackage < Package
    @word_re = Regexp.new('^\w+$')
    @version_re = Regexp.new('\d+\.\d+\.\d+')

    class << self
      def new_from_show_dep(dep)
        raise_if_not_valid(dep)
        new(
          dep_name(dep),
          dep_version(dep),
          homepage: dep_repo(dep),
          install_path: dep_path(dep)
        )
      end

      def dep_name(dep)
        _dep_parent, dep_name, _dep_fetch_method, _dep_repo, _dep_version_str, _dep_absolute_path = dep.split
        dep_name
      end

      def dep_version(dep)
        _dep_parent, _dep_name, _dep_fetch_method, _dep_repo, dep_version_str, _dep_absolute_path = dep.split
        fixup_dep_version(dep_version_str)
      end

      def dep_repo(dep)
        _dep_parent, _dep_name, _dep_fetch_method, dep_repo, _dep_version_str, _dep_absolute_path = dep.split
        fixup_dep_repo(dep_repo)
      end

      def dep_path(dep)
        _dep_parent, _dep_name, _dep_fetch_method, _dep_repo, _dep_version_str, dep_absolute_path = dep.split
        dep_absolute_path
      end

      def raise_if_not_valid(dep)
        invalid_dep = "'#{dep}' does not look like a valid Erlank.mk dependency"
        valid_dep_example = "A valid dependency example: 'lager: goldrush git https://github.com/DeadZen/goldrush.git 0.1.9'"
        raise(InvalidErlangmkPackageError, "#{invalid_dep}. #{valid_dep_example}") unless valid?(dep)
      end

      def valid?(dep)
        dep_parent, dep_name, dep_fetch_method, dep_repo, dep_version_str, _dep_absolute_path = dep.split
        dep_valid?(dep_parent) && dep_valid?(dep_name) && dep_valid?(dep_fetch_method) && dep_repo_valid?(dep_repo) && dep_version_valid?(dep_version_str)
      end

      private

      def fixup_dep_repo(dep_repo)
        dep_repo.delete_suffix('.git').sub('git@github.com:', 'https://github.com/')
      end

      def fixup_dep_version(dep_version_str)
        dep_version_str.delete_prefix('v')
      end

      def dep_valid?(arg_dep)
        return false if arg_dep.nil? || arg_dep.empty?

        dep = arg_dep.chomp(':')
        @word_re.match?(dep)
      end

      def dep_repo_valid?(arg_dep_repo)
        return false if arg_dep_repo.nil? || arg_dep_repo.empty?

        dep_repo = fixup_dep_repo(arg_dep_repo)
        _dep_repo = URI.parse(dep_repo)
        true
      end

      def dep_version_valid?(arg_dep_version_str)
        return false if arg_dep_version_str.nil? || arg_dep_version_str.empty?

        dep_version_str = fixup_dep_version(arg_dep_version_str)
        if @version_re.match?(dep_version_str)
          Gem::Version.correct?(dep_version_str)
        else
          @word_re.match?(arg_dep_version_str)
        end
      end
    end

    def package_manager
      'Erlangmk'
    end
  end
end
