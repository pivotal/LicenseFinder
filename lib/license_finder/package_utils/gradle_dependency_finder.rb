# frozen_string_literal: true

module LicenseFinder
  class GradleDependencyFinder
    def initialize(project_path)
      @project_path = project_path
    end

    def dependencies
      Pathname
        .glob(@project_path.join('**', 'dependency-license.xml'))
        .map(&:read)
    end
  end
end
