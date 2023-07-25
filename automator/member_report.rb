class MemberReport
  def initialize(member, day, session)
    @member = member
    @day = day
    @session = session
  end

  def issues
    filter.issues
  end

  def filter
    JiraJQLFilter.new "status changed by (#{@member})  during ('#{jira_date(@day)}', '#{jira_date(@day + 1.day)}') or (assignee = #{@member} and status = \"In Progress\" ) and type != Epic order by priority, updated asc", @session
  end

  def jira_date(dt)
    dt.strftime '%Y-%m-%d 00:00'
  end
end
