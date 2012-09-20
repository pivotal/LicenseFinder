module LicenseFinder
  class DependencyReport
    def self.underscored_name
      @underscored_name ||= begin
        str = name.dup
        str.sub!(/.*::/, '')
        str.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
        str.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        str.downcase!
      end
    end

    def initialize(dependencies=[])
      @dependencies = Array dependencies
    end

    def to_s
      filename = File.join(File.dirname(__FILE__), '..', 'templates', "#{self.class.underscored_name}.erb")
      template = ERB.new(File.read(filename))
      template.result(binding)
    end

    private
    attr_reader :dependencies

    def sorted_dependencies
      dependencies.sort_by(&:name)
    end
  end
end
