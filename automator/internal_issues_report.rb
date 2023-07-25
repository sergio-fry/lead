require_relative 'jira_jql_filter'

class InternalIssuesReport
  def initialize(session)
    @session = session
  end

  def vip_assignees_count
    filter("filter in ('cash/v1/team') and status = 'In Progress' and labels = vip")
      .counts_by_assignee.keys.count
  end

  def non_business_assignees_count
    filter("filter in ('cash/v1/team') and status = 'In Progress' and labels in (vip, non-business)")
      .counts_by_assignee.keys.count
  end

  def filter(jql)
    JiraJQLFilter.new(jql, @session)
  end
end
