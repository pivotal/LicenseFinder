module LicenseFinder
  class HtmlReport < FormattedReport
    def link_to_license(license)
      if license.url && !license.url.empty?
        %{<a href="#{license.url}">#{license.name}</a>}
      else
        license.name
      end
    end
  end
end
