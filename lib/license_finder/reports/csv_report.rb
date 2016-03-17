require 'csv'

module LicenseFinder
  class CsvReport < Report
    COMMA_SEP =  ","
    AVAILABLE_COLUMNS = %w[name version authors licenses approved summary description homepage install_path package_manager groups parents children]
    MISSING_DEPENDENCY_TEXT = "This package is not installed. Please install to determine licenses."

    def initialize(dependencies, options)
      super
      @columns = Array(options[:columns]) & self.class::AVAILABLE_COLUMNS
    end

    def to_s
      CSV.generate(col_sep: self.class::COMMA_SEP) do |csv|
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

    def format_approved(dep)
      dep.approved? ? "Approved" : "Not approved"
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
      dep.groups.join(",")
    end
    
    def format_parents(dep)
      dep.parents.to_a.join(self.class::COMMA_SEP)
    end

    def format_children(dep)
      dep.children.to_a.join(self.class::COMMA_SEP)
    end
  end
end
