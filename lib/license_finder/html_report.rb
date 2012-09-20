# encoding: UTF-8

module LicenseFinder
  class HtmlReport < DependencyReport
    private
    def unapproved_dependencies
      dependencies.reject(&:approved)
    end

    def grouped_dependencies
      dependencies.group_by(&:license).sort_by { |_, group| group.size }.reverse
    end
  end
end
