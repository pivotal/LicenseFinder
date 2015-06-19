module LicenseFinder
  class GradleDependencyFinder
    def initialize(path)
      @path = path
    end

    def dependencies
      [].tap do |files|
        Dir.glob("#{@path}/**/dependency-license.xml") do |file|
          files << File.open(file).read
        end
      end
    end
  end
end
