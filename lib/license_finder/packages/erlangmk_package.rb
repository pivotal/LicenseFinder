require 'rubygems'

class InvalidErlangmkPackageError < ArgumentError
end

# NOTE: make query-deps output
# make[1]: Leaving directory '/home/lbakken/development/rabbitmq/umbrella/deps/recon'
# make[1]: Entering directory '/home/lbakken/development/rabbitmq/umbrella/deps/credentials_obfuscation'
# make[1]: Leaving directory '/home/lbakken/development/rabbitmq/umbrella/deps/credentials_obfuscation'
# rabbit_common: rabbitmq_codegen git_rmq https://github.com/rabbitmq/rabbitmq-codegen master
# rabbit_common: lager hex https://hex.pm/packages/lager 3.8.0
# rabbit_common: jsx hex https://hex.pm/packages/jsx 2.9.0
# rabbit_common: ranch hex https://hex.pm/packages/ranch 1.7.1
# rabbit_common: recon hex https://hex.pm/packages/recon 2.5.1
# rabbit_common: credentials_obfuscation hex https://hex.pm/packages/credentials_obfuscation 2.0.0
# lager: goldrush git https://github.com/DeadZen/goldrush.git 0.1.9

module LicenseFinder
  class ErlangmkPackage < Package

    @@word_re = Regexp.new('^\w+$')

    class << self
      def new_from_show_dep(dep)
        raise_if_not_valid(dep)
        new(
          dep_name(dep),
          dep_version(dep),
          homepage: dep_url(dep),
          install_path: dep_path(dep)
        )
      end

      def dep_name(dep)
        _dep_parent, dep_name, _dep_source, _dep_uri_str, _dep_version_str = dep.split
        dep_name
      end

      def dep_version(dep)
        _dep_parent, _dep_name, _dep_source, _dep_uri_str, dep_version_str = dep.split
        dep_version_str.delete_prefix('v')
      end

      def dep_url(dep)
        _dep_parent, _dep_name, _dep_source, dep_uri_str, _dep_version_str = dep.split
        # TODO: why is .git here?
        # dep_uri_str.split('.git')[0].sub('git@github.com:', 'https://github.com/')
        dep_uri_str.sub('git@github.com:', 'https://github.com/')
      end

      def dep_path(dep)
        _dep_parent, dep_name, _dep_source, _dep_uri_str, _dep_version_str = dep.split
        # TODO
        dep_name
      end

      def raise_if_not_valid(dep)
        invalid_dep = "'#{dep}' does not look like a valid Erlank.mk dependency"
        # valid_dep_example = "A valid dependency example: 'DEPI	  ra	WIP_fetch_method	1.0.7	https://hex.pm/packages/ra	/erlangmk/project/path/deps/ra'"
        valid_dep_example = "A valid dependency example: 'lager: goldrush git https://github.com/DeadZen/goldrush.git 0.1.9'"
        raise(InvalidErlangmkPackageError, "#{invalid_dep}. #{valid_dep_example}") unless valid?(dep)
      end

      # 'license_finder_noop_library: rabbitmq_management git https://github.com/rabbitmq/rabbitmq-management v3.8.5'
      def valid?(dep)
        # TODO
        # dep.start_with?('DEPI')
        dep_parent, dep_name, dep_source, dep_uri_str, dep_version_str = dep.split
        dep_valid?(dep_parent) and dep_valid?(dep_name) and dep_valid?(dep_source) and dep_uri_valid?(dep_uri_str) and dep_version_valid?(dep_version_str)
      end

      private

      def dep_valid?(dep)
        dep = dep.chomp(':')
        @@word_re.match?(dep)
      end

      def dep_uri_valid?(dep_uri_str)
        _dep_uri = URI.parse(dep_uri_str)
        true
      end

      def dep_version_valid?(dep_version_str)
        dvs = dep_version_str.delete_prefix('v')
        Gem::Version.correct?(dvs)
      end
    end

    def package_manager
      'Erlangmk'
    end

  end
end
