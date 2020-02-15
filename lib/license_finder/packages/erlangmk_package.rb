# frozen_string_literal: true

class InvalidErlangmkPackageError < ArgumentError
end

module LicenseFinder
  class ErlangmkPackage < Package
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
        dep_path(dep)
          .split('/')[-1]
      end

      def dep_version(dep)
        dep
          .split(' ')[1]
      end

      def dep_url(dep)
        dep
          .split(' ')[-1]
          .split('.git')[0]
          .sub('git@github.com:', 'https://github.com/')
      end

      def dep_path(dep)
        dep
          .split(' ')[0]
      end

      def raise_if_not_valid(dep)
        invalid_dep = "'#{dep}' does not look like a valid Erlank.mk dependency"
        valid_dep_example = "A valid dependency example: '/erlangmk/project/path/deps/ra 1.0.7 https://hex.pm/packages/ra'"
        raise(InvalidErlangmkPackageError, "#{invalid_dep}. #{valid_dep_example}") unless valid?(dep)
      end

      def valid?(dep)
        dep.split(' ').size == 3
      end
    end

    def package_manager
      'Erlangmk'
    end
  end
end
