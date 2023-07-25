class JiraFilter
  def initialize(id, session)
    @id = id
    @session = session
  end

  def issues
    result = []

    CSV.parse(issues_csv, headers: true) do |row|
      result << Issue.new(
        key: row['Issue key'],
        summary: row['Summary'],
        type: row['Type'],
        status: row['Status'],
        assignee: row['Assignee'],
        priority: row['Priority'],
        labels: row['Labels'].to_s.split(','),
      )
    end

    result
  end

  def counts_by_priority
    Hash[issues.group_by(&:priority).map { |x, y| [x, y.size] }]
  end

  def counts_by_status
    Hash[issues.group_by(&:status).map { |x, y| [x, y.size] }]
  end

  def counts_by_assignee
    h = {}

    issues.each do |issue|
      h[issue.assignee] ||= { status: {}, priority: {}, total: 0 }

      h[issue.assignee][:total] += 1

      h[issue.assignee][:priority][issue.priority] ||= 0
      h[issue.assignee][:priority][issue.priority] += 1

      h[issue.assignee][:status][issue.status] ||= 0
      h[issue.assignee][:status][issue.status] += 1
    end

    h
  end

  def issues_csv
    HTTP
      .timeout(30)
      .cookies(JSESSIONID: @session.id)
      .get(url_csv)
      .to_s
  end

  def url
    "https://jira.balance-pl.ru/issues/?filter=#{@id}"
  end

  def url_csv
    "https://jira.balance-pl.ru/sr/jira.issueviews:searchrequest-csv-current-fields/#{@id}/SearchRequest-#{@id}.csv"
  end
end
