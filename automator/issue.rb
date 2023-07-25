class Issue
  def initialize(key:, type:, status:, assignee:, priority:, summary:, labels: [])
    @key = key
    @type = type
    @status = status
    @assignee = assignee
    @priority = priority
    @summary = summary
    @labels = labels
  end

  attr_reader(
    :assignee,
    :key,
    :labels,
    :priority,
    :status,
    :summary,
  )

  def vip?
    labels.include? 'vip'
  end
end
