# encoding: utf-8

module LicenseFinder
  class DependencyList
    attr_reader :dependencies

    def self.from_bundler
      dep_list = new(Bundle.new.gems.map(&:to_dependency))
      dep_list.dependencies.each do |dep|
        dep.children.each do |child_dep|
          dep_list.dependencies.select { |d| d.name == child_dep.name }.each do |found_child|
            found_child.parents << dep
          end
        end
      end
      dep_list
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
              body {
                margin: 50px;
              }

              .unapproved h2, .unapproved h2 a {
                color: red;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="summary hero-unit">
                <h1>Dependencies</h1>

                <h4>
                  <%= dependencies.size %> total

                  <% if unapproved_dependencies.any? %>
                    <span class="badge badge-important"><%= unapproved_dependencies.size %> unapproved</span>
                  <% end %>
                </h4>

                <ul>
                  <% grouped_dependencies.each do |license, group| %>
                    <li><%= group.size %> <%= license %></li>
                  <% end %>
                </ul>
              </div>
              <div class="dependencies">
                <%= sorted_dependencies.map(&:to_html).join("\n") %>
              </div>
            </div>
          </body>
        </html>
      HTML

      template.result binding
    end

    private

    def unapproved_dependencies
      dependencies.reject(&:approved)
    end

    def sorted_dependencies
      dependencies.sort_by(&:name)
    end

    def grouped_dependencies
      dependencies.group_by(&:license).sort_by { |_, group| group.size }.reverse
    end
  end
end
