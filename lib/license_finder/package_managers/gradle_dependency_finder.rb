module LicenseFinder
  class GradleDependencyFinder
    def initialize(project_path)
      @project_path = project_path
    end

    def dependencies
      [].tap do |files|
        Dir.glob("#{@project_path}/**/dependency-license.xml") do |file|
          files << File.open(file).read
        end
      end
    end
  end
end
