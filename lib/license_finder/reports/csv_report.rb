require 'csv'

module LicenseFinder
  class CsvReport < Report
    COMMA_SEP = ','.freeze
    NEWLINE_SEP = '\@NL'.freeze
    AVAILABLE_COLUMNS = %w[name version authors licenses license_links approved summary description homepage install_path package_manager groups texts notice].freeze
    MISSING_DEPENDENCY_TEXT = 'This package is not installed. Please install to determine licenses.'.freeze

    def initialize(dependencies, options)
      super
      options[:columns] ||= %w[name version licenses]
      @columns = Array(options[:columns]) & self.class::AVAILABLE_COLUMNS
      @write_headers = options[:write_headers] || false
    end

    def to_s
      CSV.generate(col_sep: self.class::COMMA_SEP, headers: @columns, write_headers: @write_headers) do |csv|
        sorted_dependencies.each do |s|
          csv << format_dependency(s)
        end
      end
    end

    private

    def format_dependency(dep)
      @columns.map do |column|
        send("format_#{column}", dep)
      end
    end

    def format_texts(dep)
      dep.license_files.map { |file| file.text.split(/[\n\r]+/).join(self.class::NEWLINE_SEP) }
          .join(self.class::NEWLINE_SEP).force_encoding("ISO-8859-1").encode("UTF-8")
    end

    def format_notice(dep)
      dep.notice_files.map { |file| file.text.split(/[\n\r]+/).join(self.class::NEWLINE_SEP) }
          .join(self.class::NEWLINE_SEP).force_encoding("ISO-8859-1").encode("UTF-8")
    end

    def format_name(dep)
      dep.name
    end

    def format_version(dep)
      dep.version
    end

    def format_authors(dep)
      dep.authors.to_s.strip
    end

    def format_homepage(dep)
      dep.homepage
    end

    def format_licenses(dep)
      if dep.missing?
        MISSING_DEPENDENCY_TEXT
      else
        dep.licenses.map(&:name).join(self.class::COMMA_SEP)
      end
    end

    def format_license_links(dep)
      dep.licenses.map(&:url).join(self.class::COMMA_SEP)
    end

    def format_approved(dep)
      dep.approved? ? 'Approved' : 'Not approved'
    end

    def format_summary(dep)
      dep.summary.to_s.strip
    end

    def format_description(dep)
      dep.description.to_s.strip
    end

    def format_install_path(dep)
      dep.install_path
    end

    def format_package_manager(dep)
      dep.package_manager
    end

    def format_groups(dep)
      if dep.groups.nil?
        ''
      else
        dep.groups.join(self.class::COMMA_SEP)
      end
    end
  end
end
