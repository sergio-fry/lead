class MemberReportTempo
  def initialize(member, day, session)
    @member = member
    @day = day
    @session = session
  end

  def issues
    filter.issues
  end

  def report_hash
    resp = HTTP.basic_auth(user: ENV.fetch('JIRA_LOGIN'), pass: ENV.fetch('JIRA_PASSWORD'))
      .headers(content_type: 'application/json')
      .post('https://jira.balance-pl.ru/rest/tempo-timesheets/4/worklogs/export/filter', json: { from: tempo_date(@day), to: tempo_date(@day) })

    JSON.parse(resp.body)['filterKey']
  end

  def tempo_csv
    HTTP
      .cookies(JSESSIONID: @session.id)
      .get("https://jira.balance-pl.ru/rest/tempo-timesheets/4/worklogs/export/#{report_hash}\?format\=csv\&title\=report").to_s
  end

  def member_issue_keys
    CSV.parse(tempo_csv, headers: true).find_all do |row|
      row['Username'] == @member
    end.map do |row|
      row['Issue Key']
    end
  end

  def member_issue_keys_cached
    @member_issue_keys_cached ||= member_issue_keys
  end

  def filter
    if member_issue_keys_cached.empty?
      JiraJQLFilter.new 'key in (EMPTY-1) order by priority, updated asc', @session
    else
      JiraJQLFilter.new "key in (#{member_issue_keys_cached.join(",")}) order by priority, updated asc", @session
    end
  end

  def tempo_date(dt)
    dt.strftime '%Y-%m-%d'
  end
end
