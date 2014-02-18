module LicenseFinder
  module Reporter
    extend self

    def write_reports
      dependencies = Dependency.all

      write_file LicenseFinder.config.artifacts.dependencies_text, TextReport.new(dependencies).to_s
      write_file LicenseFinder.config.artifacts.dependencies_detailed_text, DetailedTextReport.new(dependencies).to_s
      write_file LicenseFinder.config.artifacts.dependencies_html, HtmlReport.new(dependencies).to_s
      write_file LicenseFinder.config.artifacts.dependencies_markdown, MarkdownReport.new(dependencies).to_s

      if LicenseFinder.config.artifacts.legacy_dependencies_text.exist?
        LicenseFinder.config.artifacts.legacy_dependencies_text.delete
      end
    end

    private
    def write_file(file_path, content)
      file_path.open('w+') do |f|
        f.puts content
      end
    end
  end
end

