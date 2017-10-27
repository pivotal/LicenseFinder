require 'erb'

module LicenseFinder
  class ErbReport < Report
    TEMPLATE_PATH = ROOT_PATH.join('reports', 'templates')

    def to_s(filename = TEMPLATE_PATH.join("#{template_name}.erb"))
      template = ERB.new(filename.read, nil, '-')
      template.result(binding)
    end

    private

    def unapproved_dependencies
      dependencies.reject(&:approved?)
    end

    def grouped_dependencies
      dependencies
        .group_by { |dep| license_names(dep) }
        .sort_by { |_, group| -group.size }
    end

    def link_to_license(license)
      link_to_maybe license.name, license.url
    end

    def link_to_dependency(dependency)
      link_to_maybe dependency.name, dependency.homepage
    end

    def link_to_maybe(text, link)
      if link && !link.empty?
        link_to(text, link)
      else
        text
      end
    end

    def link_to(text, link = "##{text}")
      %(<a href="#{link}">#{text}</a>)
    end

    def license_names(dependency)
      dependency.licenses.map(&:name).sort.join ', '
    end

    def license_links(dependency)
      dependency.licenses.map { |l| link_to_license(l) }.join(', ')
    end

    def version_groups(dependency)
      result = "v#{dependency.version}"
      result << " (#{dependency.groups.join(', ')})" if dependency.groups.any?
      result
    end
  end
end
