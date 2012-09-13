# encoding: UTF-8
require "erb"

module LicenseFinder
  class Dependency
    attr_accessor :name, :version, :license, :approved, :license_url, :notes, :license_files,
      :readme_files, :source, :bundler_groups

    attr_reader :summary, :description

    def self.from_hash(attrs)
      attrs['license_files'] = attrs['license_files'].map { |lf| lf['path'] } if attrs['license_files']
      attrs['readme_files'] = attrs['readme_files'].map { |rf| rf['path'] } if attrs['readme_files']

      new(attrs)
    end

    def initialize(attributes = {})
      @source = attributes['source']
      @name = attributes['name']
      @version = attributes['version']
      @license = attributes['license']
      @approved = attributes['approved'] || LicenseFinder.config.whitelist.include?(attributes['license'])
      @license_url = attributes['license_url'] || ''
      @notes = attributes['notes'] || ''
      @license_files = attributes['license_files'] || []
      @readme_files = attributes['readme_files'] || []
      @bundler_groups = attributes['bundler_groups'] || []
      @summary = attributes['summary']
      @description = attributes['description']
    end

    def merge(other)
      raise "Cannot merge dependencies with different names. Expected #{name}, was #{other.name}." unless other.name == name

      merged = self.class.new(
        'name' => name,
        'version' => other.version,
        'license_files' => other.license_files,
        'readme_files' => other.readme_files,
        'license_url' => other.license_url,
        'notes' => notes,
        'source' => other.source,
        'summary' => other.summary,
        'description' => other.description,
        'bundler_groups' => other.bundler_groups,
      )

      case other.license
      when license, 'other'
        merged.license = license
        merged.approved = approved
      else
        merged.license = other.license
        merged.approved = other.approved
      end

      merged
    end

    def as_yaml
      attrs = {
        'name' => name,
        'version' => version,
        'license' => license,
        'approved' => approved,
        'source' => source,
        'license_url' => license_url,
        'notes' => notes,
        'license_files' => nil,
        'readme_files' => nil
      }

      unless license_files.empty?
        attrs['license_files'] = license_files.map do |file|
          {'path' => file}
        end
      end

      unless readme_files.empty?
        attrs['readme_files'] = readme_files.map do |file|
          {'path' => file}
        end
      end

      attrs
    end

    def to_yaml
      as_yaml.to_yaml
    end

    def to_html
      css_class = approved ? "approved" : "unapproved"

      template = ERB.new <<-HTML
        <div id="<%=name%>" class="<%=css_class%>">
          <h2><%=name%> v<%=version%></h2>
          <table class="table table-striped table-bordered">
            <thead>
              <tr>
                <th>Summary</th>
                <th>Description</th>
                <th>License</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><%= summary %></td>
                <td><%= description %></td>
                <td><%= license %></td>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      HTML

      template.result binding
    end

    def to_s
      template = ERB.new <<-TEMPLATE
<%= attributes.join(", ") %>
<% if license == 'other' %>
  <% unless license_files.empty? %>
  license files:
    <%= license_files.join("\n    ") %>
  <% end %>
  <% unless readme_files.empty? %>
  readme files:
    <%= readme_files.join("\n    ") %>
  <% end %>
<% end%>
TEMPLATE

      attributes = ["#{name} #{version}".strip, license, license_url, summary, description, bundler_groups].flatten.compact.reject {|a| a == ""}

      template.result(binding).gsub(/(^|\n)\s*(\n|$)/, '\1')
    end
  end
end

