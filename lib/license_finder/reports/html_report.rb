require 'sanitize'

module LicenseFinder
  class HtmlReport < ErbReport
    private

    def template_name
      'html_report'
    end

    def bootstrap
      TEMPLATE_PATH.join('bootstrap.css').read
    end

    def sanitize(content)
      Sanitize.fragment(content, Sanitize::Config::RESTRICTED)
    end
  end
end
