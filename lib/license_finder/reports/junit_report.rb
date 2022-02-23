require 'license_finder/reports/erb_report'

module LicenseFinder
  class JunitReport < ErbReport
    ROOT_PATH = Pathname.new(__FILE__).dirname
    TEMPLATE_PATH = ROOT_PATH.join('templates')

    def to_s(filename = TEMPLATE_PATH.join("#{template_name}.erb"))
      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.6.0')
        template = ERB.new(filename.read, nil, '-')
      else
        template = ERB.new(filename.read, trim_mode: '-')
      end
      template.result(binding)
    end

    private

    def template_name
      'junit_report'
    end
  end
end
