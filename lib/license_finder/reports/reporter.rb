module LicenseFinder
  module Reporter
    extend self

    def write_reports
      dependencies = Dependency.all

      write_file LicenseFinder.config.artifacts.text_file, TextReport.new(dependencies).to_s
      write_file LicenseFinder.config.artifacts.detailed_text_file, DetailedTextReport.new(dependencies).to_s
      write_file LicenseFinder.config.artifacts.html_file, HtmlReport.new(dependencies).to_s
      write_file LicenseFinder.config.artifacts.markdown_file, MarkdownReport.new(dependencies).to_s

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

