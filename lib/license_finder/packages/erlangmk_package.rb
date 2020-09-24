# frozen_string_literal: true

require 'rubygems'

class InvalidErlangmkPackageError < ArgumentError
end

module LicenseFinder
  class ErlangmkPackage < Package
    attr_reader :dep_parent,
                :dep_name,
                :dep_fetch_method,
                :dep_repo_unformatted,
                :dep_version_unformatted,
                :dep_absolute_path

    def initialize(dep_string_from_query_deps)
      @dep_parent,
      @dep_name,
      @dep_fetch_method,
      @dep_repo_unformatted,
      @dep_version_unformatted,
      @dep_absolute_path = dep_string_from_query_deps.split

      raise_invalid(dep_string_from_query_deps) unless all_parts_valid?

      super(
        dep_name,
        dep_version,
        homepage: dep_repo,
        install_path: dep_absolute_path
      )
    end

    def package_manager
      'Erlangmk'
    end

    def dep_version
      @dep_version ||= begin
        dep_version_unformatted.sub(version_prefix_re, '')
      end
    end

    def dep_repo
      @dep_repo ||= dep_repo_unformatted
                    .chomp('.git')
                    .sub('git@github.com:', 'https://github.com/')
    end

    def raise_invalid(dep_string)
      invalid_dep_message = "'#{dep_string}' does not look like a valid Erlank.mk dependency"
      valid_dep_example = "A valid dependency example: 'lager: goldrush git https://github.com/DeadZen/goldrush.git 0.1.9 /absolute/path/to/dep'"
      raise(InvalidErlangmkPackageError, "#{invalid_dep_message}. #{valid_dep_example}")
    end

    def all_parts_valid?
      dep_part_valid?(dep_parent) &&
        dep_part_valid?(dep_name) &&
        set?(dep_fetch_method) &&
        dep_repo_valid? &&
        dep_version_valid? &&
        set?(dep_absolute_path)
    end

    private

    def dep_part_valid?(dep_part)
      set?(dep_part) &&
        word?(dep_part)
    end

    def set?(dep_part)
      !dep_part.nil? &&
        !dep_part.empty?
    end

    def word?(dep_part)
      dep = dep_part.chomp(':')
      dep =~ word_re
    end

    def dep_repo_valid?
      set?(dep_repo_unformatted) &&
        URI.parse(dep_repo)
    end

    def dep_version_valid?
      return false unless set?(dep_version_unformatted)

      if dep_version =~ version_re
        Gem::Version.correct?(dep_version)
      else
        dep_version =~ word_dot_re
      end
    end

    def version_re
      @version_re ||= Regexp.new('\d+\.\d+\.\d+')
    end

    def version_prefix_re
      @version_prefix_re ||= Regexp.new('^v')
    end

    def word_re
      @word_re ||= Regexp.new('^\w+$')
    end

    def word_dot_re
      @word_dot_re ||= Regexp.new('^[.\w]+$')
    end
  end
end
