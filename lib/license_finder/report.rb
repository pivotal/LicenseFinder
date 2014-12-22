module LicenseFinder
  class Report
    def self.of(dependencies, project_name)
      new(dependencies, project_name).to_s
    end

    def initialize(dependencies=[], project_name=nil)
      @dependencies = Array(dependencies)
      @project_name = project_name || determine_project_name
    end

    private
    attr_reader :dependencies, :project_name

    def sorted_dependencies
      dependencies.sort_by(&:name)
    end

    def determine_project_name
      Pathname.pwd.basename.to_s
    end
  end
end

require 'license_finder/reports/formatted_report'
require 'license_finder/reports/csv_report'
require 'license_finder/reports/html_report'
require 'license_finder/reports/markdown_report'
require 'license_finder/reports/text_report'
require 'license_finder/reports/detailed_text_report'
require 'license_finder/reports/status_report'
