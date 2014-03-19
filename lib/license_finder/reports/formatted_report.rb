module LicenseFinder
  class FormattedReport < DependencyReport
    private
    def unapproved_dependencies
      dependencies.reject(&:approved?)
    end

    def grouped_dependencies
      find_name = lambda do |dep|
        dep.license.name
      end

      dependencies.group_by(&find_name).sort_by { |_, group| group.size }.reverse
    end
  end
end
