# frozen_string_literal: true

module LicenseFinder
  class SbtDependencyFinder
    def initialize(project_path)
      @project_path = project_path
    end

    def dependencies
      Pathname
        .glob(@project_path.join('**', 'target', 'license-reports', '*.csv'))
        .map(&:read)
    end
  end
end
