require 'govuk_tech_docs'

GovukTechDocs::SourceUrls.class_eval do
  def report_issue_url
    'mailto:idasupport@digital.cabinet-office.gov.uk'
  end
end

GovukTechDocs.configure(self)
