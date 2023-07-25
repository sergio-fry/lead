require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'http'
  gem 'byebug'
  gem 'activesupport'
  gem 'tty-prompt'
end

require 'active_support/all'
require 'http'
require 'csv'
require 'tty-prompt'

require_relative 'jira_session'
require_relative 'issue'
require_relative 'slack_hook'
require_relative 'jira_jql_filter'
require_relative 'member_report'
require_relative 'member_report_tempo'

require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

HTTP.default_options = HTTP::Options.new(features: {
  logging: {
    logger: logger,
  },
})

session = JiraSession.new

def previous_day
  today = Time.now

  if today.wday == 1
    (today - 3.day).beginning_of_day
  else
    (today - 1.day).beginning_of_day
  end
end

def jira_date(dt)
  dt.strftime '%Y-%m-%d 00:00'
end

class SlackMessage
  def initialize(blocks)
    @blocks = blocks
  end

  def as_text
    @blocks.map { |el| el.dig(:text, :text) }.join("\n")
  end
end

team = {
  "U01GV6N8L57": 'alexander.polyakov',
  "U015ZUV53FE": 'arseny.karashkevich',
  "U016FJJELF7": 'artem.sablin',
  "UKM1AJMV3": 'd.sidorov',
  "UR21FHU76": 'evgeny.barabanov',
  "U8X3EHKMY": 'pavel.kosykh',
  "UL125AF52": 'v.perederenko',
  "UMURL8GVB": 's.udalov',
}

report = []

report << {
  "type": 'header',
  "text": {
    "type": 'plain_text',
    "text": "Morning Standup Report, #{previous_day.strftime "%Y-%m-%d"}",
  },
}

team.each do |id, member|
  # filter = MemberReport.new member, previous_day, session
  filter = MemberReportTempo.new member, previous_day, session

  report << {
    "type": 'section',
    "text": {
      "type": 'mrkdwn',
      "text": <<~MARKDOWN,
        *<@#{id}>*

        #{filter.issues.map { |issue| "[<https://jira.balance-pl.ru/browse/#{issue.key}|#{issue.key}>] #{'*VIP*' if issue.vip?} #{issue.summary} - #{issue.status}" }.join("\n")}
        \n\n
      MARKDOWN
    },
  }

  report << {
    "type": 'divider',
  }
end

report << {
  "type": 'section',
  "text": {
    "type": 'mrkdwn',
    "text": <<~MARKDOWN,
      *P.S.*. _Если данные в отчете не соответсвуют действительности, необходимо в треде к этому сообщению написать, чем ты *фактически* занимался в этот день._
      \n\n
    MARKDOWN
  },
}

SLACK_CHANNEL = 'cashrgsdev'
# SLACK_CHANNEL = 'su-notifications'

prompt = TTY::Prompt.new

message = SlackMessage.new report

puts message.as_text

if prompt.yes?("Send report to #{SLACK_CHANNEL}?")
  hook = SlackHook.new 'https://hooks.slack.com/services/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', SLACK_CHANNEL
  hook.post_blocks report
end
