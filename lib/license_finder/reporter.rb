module LicenseFinder
  module Reporter
    extend self

    def write_reports
      dependencies = Dependency.all

      write_file LicenseFinder.config.dependencies_text, TextReport.new(dependencies).to_s
      write_file LicenseFinder.config.dependencies_html, HtmlReport.new(dependencies).to_s
    end

    private
    def write_file(file_path, content)
      File.open(file_path, 'w+') do |f|
        f.puts content
      end
    end
  end
end

