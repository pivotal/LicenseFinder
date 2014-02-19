module LicenseFinder
  module Reporter
    extend self

    def write_reports
      dependencies = Dependency.all
      artifacts = LicenseFinder.config.artifacts

      write_file artifacts.text_file,          TextReport.of(dependencies)
      write_file artifacts.detailed_text_file, DetailedTextReport.of(dependencies)
      write_file artifacts.html_file,          HtmlReport.of(dependencies)
      write_file artifacts.markdown_file,      MarkdownReport.of(dependencies)

      if LicenseFinder.config.artifacts.legacy_text_file.exist?
        LicenseFinder.config.artifacts.legacy_text_file.delete
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

