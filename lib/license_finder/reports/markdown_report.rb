module LicenseFinder
  class MarkdownReport < ErbReport
    private

    def template_name
      'markdown_report'
    end
  end
end
