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

    def link_to_license(license)
      link_to_maybe license.name, license.url
    end

    def link_to_dependency(dependency)
      link_to_maybe dependency.name, dependency.homepage
    end

    def link_to_maybe(text, link)
      if link && !link.empty?
        %{<a href="#{link}">#{text}</a>}
      else
        text
      end
    end

    def version_groups(dependency)
      result = "v#{dependency.version}"
      if dependency.bundler_groups.any?
        result += " (#{dependency.bundler_groups.map(&:name).join(", ")})"
      end
      result
    end
  end
end
