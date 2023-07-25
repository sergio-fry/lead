require 'json'
require 'faraday'

module Lead
  class Tower
    HOST_NAME = 'https://tower.infra.b-pl.pro'
    BASE_URL = 'api/v2'
    TEMPLATES_PATH = 'job_templates/:id/launch/'
    JOBS_PATH = 'jobs/:id'

    def deploy(project, vars)
      path = job_template_url(project)
      task_json = { extra_vars: vars }.to_json
      request_info = { request: { path: path, payload: task_json } }

      result = nil
      with_connect do |conn|
        result = conn.post do |req|
          req.url path
          req.headers['Content-Type'] = 'application/json'
          req.body = task_json
        end
      end

      raise "Tower error: #{result.body} (#{result.status})" unless [200, 201].include?(result.status)

      data = {}
      data.merge!(request_info)
      data.merge!(JSON.parse(result.body))
      data['url'] = "#{HOST_NAME}/#/jobs/playbook/#{data["job"]}"

      data
    end

    def job_template_url(project)
      [
        BASE_URL,
        TEMPLATES_PATH.gsub(':id', project.to_s),
      ].join('/')
    end

    def with_connect()
      Faraday.new(url: HOST_NAME, ssl: { verify: false }) do |conn|
        conn.adapter Faraday.default_adapter # make requests with Net::HTTP
        conn.basic_auth(ENV.fetch('TOWER_USER'), ENV.fetch('TOWER_PASSWORD'))
        yield(conn)
      end
    end
  end
end
