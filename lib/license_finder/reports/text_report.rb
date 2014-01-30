module LicenseFinder
  class TextReport < DependencyReport
    def to_s
      super.strip
    end
  end
end
