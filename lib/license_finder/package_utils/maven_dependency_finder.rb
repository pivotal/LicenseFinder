# frozen_string_literal: true

module LicenseFinder
  class MavenDependencyFinder
    def initialize(project_path)
      @project_path = project_path
    end

    def dependencies
      Pathname
        .glob(@project_path.join('**', 'target', 'generated-resources', 'licenses.xml'))
        .map(&:read)
    end
  end
end
