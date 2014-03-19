module LicenseFinder
  class FormattedReport < DependencyReport
    private
    def unapproved_dependencies
      dependencies.reject(&:approved?)
    end

    def grouped_dependencies
      find_name = lambda do |dep|
        license = License.find_by_name(dep.license.name)
        if license
          license.pretty_name
        else
          dep.license.name
        end
      end

      dependencies.group_by(&find_name).sort_by { |_, group| group.size }.reverse
    end

    def link_to_license(license)
      if license.url && !license.url.empty?
        %{<a href="#{license.url}">#{license.name}</a>}
      else
        license.name
      end
    end
  end
end
