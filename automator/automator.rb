require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  # gem "activesupport"
  gem 'rufus-scheduler'
  gem 'http'
  gem 'byebug'
end

require 'rufus-scheduler'
require 'http'
require 'csv'

scheduler = Rufus::Scheduler.new

require_relative 'jira_session'
require_relative 'issue'
require_relative 'huginn_hook'
require_relative 'jira_filter'
require_relative 'internal_issues_report'

require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

HTTP.default_options = HTTP::Options.new(features: {
  logging: {
    logger: logger,
  },
})

scheduler.every 60 * 10, overlap: false, first_in: 0 do
  session = JiraSession.new
  icebox = JiraFilter.new 12532, session
  backlog = JiraFilter.new 12487, session
  my_issues = JiraFilter.new 12489, session
  team_issues = JiraFilter.new 12494, session
  internal_issues = InternalIssuesReport.new session

  data = {
    icebox: icebox.counts_by_priority,
    backlog: backlog.counts_by_priority,
    my_issues: my_issues.counts_by_status,
    team_issues: team_issues.counts_by_assignee,
    issues: {
      internal: {
        vip_assignees_count: internal_issues.vip_assignees_count,
        non_business_assignees_count: internal_issues.non_business_assignees_count,
      },
    },
  }

  hook = HuginnHook.new 'http://116.203.66.43:4070/users/2/web_requests/57/supersecretstring'

  logger.info "Trying to send #{data.inspect}"
  hook.post(data)
  logger.info 'WebHook sent'
end

logger.info 'Started'
scheduler.join
