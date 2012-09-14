# encoding: utf-8

module LicenseFinder
  class DependencyList
    attr_reader :dependencies

    def self.from_bundler
      new(Bundle.new.gems.map(&:to_dependency))
    end

    def self.from_yaml(yaml)
      deps = YAML.load(yaml)
      new(deps.map { |attrs| Dependency.from_hash(attrs) })
    end

    def initialize(dependencies)
      @dependencies = dependencies
    end

    def merge(new_list)
      deps = new_list.dependencies.map do |new_dep|
        old_dep = dependencies.detect { |d| d.name == new_dep.name }

        if old_dep
          old_dep.merge(new_dep)
        else
          new_dep
        end
      end

      deps += dependencies.select { |d| d.source != "bundle" }

      self.class.new(deps)
    end

    def as_yaml
      sorted_dependencies.map(&:as_yaml)
    end

    def to_yaml
      as_yaml.to_yaml
    end

    def to_s
      sorted_dependencies.map(&:to_s).join("\n")
    end

    def action_items
      sorted_dependencies.reject(&:approved).map(&:to_s).join "\n"
    end

    def to_html
      template = ERB.new <<-HTML
        <html>
          <head>
            <link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.1.1/css/bootstrap.min.css" rel="stylesheet">
            <style type="text/css">
            .unapproved h2, .unapproved h2 a {
              color: red;
            }
            </style>
          </head>
          <body>
            <div class="container">
              <%= sorted_dependencies.map(&:to_html).join("\n") %>
            </div>
          </body>
        </html>
      HTML

      template.result binding
    end

    private

    def sorted_dependencies
      dependencies.sort_by(&:name)
    end
  end
end
