require 'govuk_tech_docs'

GovukTechDocs::SourceUrls.class_eval do
  def report_issue_url
    'mailto:idasupport@digital.cabinet-office.gov.uk?subject=Feedback%20for%20the%20GOV.UK%20Verify%20technical%20documentation'
  end
end

GovukTechDocs.configure(self)

redirect "get-started/handle-failure-scenarios/index.html", to: "get-started/handling-failure-scenarios/index.html"
