require 'erb'

module LicenseFinder
  class ErbReport < Report
    TEMPLATE_PATH = ROOT_PATH.join('reports', 'templates')

    def to_s(filename = TEMPLATE_PATH.join("#{template_name}.erb"))
      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.6.0')
        template = ERB.new(filename.read, nil, '-')
      else
        template = ERB.new(filename.read, trim_mode: '-')
      end
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
      link_to_maybe (@use_spdx_id ? license.standard_id : license.name), license.url
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
      dependency.licenses.map(&@use_spdx_id? :standard_id : :name).sort.join ', '
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
