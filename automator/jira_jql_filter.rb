require 'cgi'
require_relative 'jira_filter'

class JiraJQLFilter < JiraFilter
  def initialize(jql, session)
    @jql = jql
    @session = session
  end

  def url
    "https://jira.balance-pl.ru/issues/?jql=#{CGI.escape(@jql)}"
  end

  def url_csv
    "https://jira.balance-pl.ru/sr/jira.issueviews:searchrequest-csv-all-fields/temp/SearchRequest.csv?jqlQuery=#{CGI.escape(@jql)}"
  end
end
