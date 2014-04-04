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

    def self.of(dependencies)
      new(dependencies).to_s
    end

    def initialize(dependencies=[])
      @dependencies = Array dependencies
    end

    def to_s
      filename = ROOT_PATH.join('templates', "#{self.class.underscored_name}.erb")
      template = ERB.new(filename.read, nil, '-')
      template.result(binding)
    end

    private
    attr_reader :dependencies

    def sorted_dependencies
      dependencies.sort_by(&:name)
    end
  end
end
