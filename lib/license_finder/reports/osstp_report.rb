require 'active_support/core_ext/hash/keys'

module LicenseFinder
  class OsstpReport < CsvReport
    def initialize(dependencies, options)
      super(dependencies, options)
    end

    def to_s
      build_deps.deep_stringify_keys.to_yaml.gsub("---\n", '')
    end

    private

    def build_deps
      all_deps = {}

      sorted_dependencies.each do |dep|

        repo = format_package_manager(dep)
        name = format_name(dep)
        version = format_version(dep)
        home_page = format_homepage(dep)
        license = format_licenses(dep)

        all_deps["#{repo.downcase}:#{name}:#{version}"] = {
            'license': license,
            'name': name,
            'url': (home_page.nil? || home_page.casecmp?('unknown')) ? 'Url Not Found' : home_page,
            'repository': repo,
            'version': version
        }
      end

      all_deps
    end

    def format_licenses(dep)
      dep.missing? ? '' : dep.licenses.map(&:name).join(',')
    end
  end
end
