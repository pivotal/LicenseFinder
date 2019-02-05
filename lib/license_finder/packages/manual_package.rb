# frozen_string_literal: true

module LicenseFinder
  class ManualPackage < Package
    def ==(other)
      eql? other
    end

    def eql?(other)
      name == other.name
    end

    def hash
      name.hash
    end

    private

    def licenses_from_spec
      Set.new
    end

    def licenses_from_files
      Set.new
    end
  end
end
