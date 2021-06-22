require 'govuk_tech_docs'

GovukTechDocs::SourceUrls.class_eval do
  def report_issue_url
    'https://www.signin.service.gov.uk/feedback?'
  end
end

GovukTechDocs.configure(self)

redirect "get-started/handle-failure-scenarios/index.html", to: "get-started/handling-failure-scenarios/index.html"
