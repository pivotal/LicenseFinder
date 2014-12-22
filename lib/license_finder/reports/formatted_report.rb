require 'erb'

module LicenseFinder
  class FormattedReport < Report
    def to_s
      filename = ROOT_PATH.join('license_finder', 'reports', 'templates', "#{self.class.template_name}.erb")
      template = ERB.new(filename.read, nil, '-')
      template.result(binding)
    end

    private
    def unapproved_dependencies
      dependencies.reject(&:approved?)
    end

    def grouped_dependencies
      find_name = lambda do |dep|
        dep.licenses.map(&:name).sort.join ', '
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
      if dependency.groups.any?
        result += " (#{dependency.groups.join(", ")})"
      end
      result
    end
  end
end
