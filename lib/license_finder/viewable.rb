module LicenseFinder
  module Viewable
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def underscored_name
        @underscored_name ||= begin
          str = name.dup
          str.sub!(/.*::/, '')
          str.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
          str.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
          str.downcase!
        end
      end
    end

    def to_yaml
      as_yaml.to_yaml
    end

    def to_html
      filename = File.join(File.dirname(__FILE__), '..', 'templates', "#{self.class.underscored_name}.html.erb")
      template = ERB.new(File.read(filename))
      template.result(binding)
    end
  end
end
