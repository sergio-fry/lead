class JiraSession
  def id
    raise "Can't authenticate" unless success?

    cookies 'JSESSIONID'
  end

  def success?
    response.headers['X-AUSERNAME'] == login
  end

  private

  def login
    ENV.fetch('JIRA_LOGIN')
  end

  def password
    ENV.fetch('JIRA_PASSWORD')
  end

  def response
    @response ||= HTTP.post("https://jira.balance-pl.ru/rest/gadget/1.0/login'", form: { os_username: login, os_password: password })
  end

  def cookies(name)
    response.cookies.find { |el| el.name == name }.value
  end
end
