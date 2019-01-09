require 'govuk_tech_docs'

GovukTechDocs::SourceUrls.class_eval do
  def report_issue_url
    'mailto:idasupport@digital.cabinet-office.gov.uk'
  end
end

# Include pages that don't end in .html when generating /api/pages.json
# See: https://github.com/alphagov/tech-docs-gem/blob/b9140b74de06b5c6298ac662f1e0d460ea2aabbf/lib/govuk_tech_docs/pages.rb#L28
GovukTechDocs::Pages.class_eval do
  private def pages
    sitemap.resources.select { |page| page.data.title }
  end
end

GovukTechDocs.configure(self)
