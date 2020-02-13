# frozen_string_literal: true

class InvalidErlangmkPackageError < ArgumentError
end

module LicenseFinder
  class ErlangmkPackage < Package
    def self.new_from_show_dep(dep)
      raise_if_not_valid(dep)
      new(
        self.dep_name(dep),
        self.dep_version(dep),
        {
          homepage: self.dep_url(dep),
          install_path: self.dep_path(dep)
        }
      )
    end

    def self.dep_name(dep)
      dep_path(dep).
        split("/")[-1]
    end

    def self.dep_version(dep)
      dep
        .split(" ")[1]
    end

    def self.dep_url(dep)
      dep
        .split(" ")[-1]
        .split(".git")[0]
        .sub("git@github.com:", "https://github.com/")
    end

    def self.dep_path(dep)
      dep
        .split(" ")[0]
    end

    def package_manager
      "Erlangmk"
    end

    private

    def self.raise_if_not_valid(dep)
      raise InvalidErlangmkPackageError.new("
        '#{dep}' does not look like a valid Erlank.mk dependency.
        A valid dependency example: '/erlangmk/project/path/deps/ra 1.0.7 https://hex.pm/packages/ra'
      ") if !valid?(dep)
    end

    def self.valid?(dep)
      dep.split(" ").size == 3
    end
  end
end
