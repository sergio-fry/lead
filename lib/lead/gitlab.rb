require 'gitlab'

module Lead
  class Gitlab
    extend Dry::Initializer
    param :project
    option :ui

    def tag_job(tag)
      ::Gitlab.jobs(project).find { |j| j['name'] == ENV.fetch('GITLAB_TAG_JOB_NAME') && j['ref'] == tag }
    end

    def wait_job!(job)
      loop do
        status = job_status(job)
        break if status == 'success'

        raise 'Job failed' if ['failed', 'canceled', 'skipped', 'manual'].include?(status)

        sleep 1
        ui.progress_tick
      end
    end

    def job_status(job)
      ::Gitlab.job(project, job['id'])['status']
    end
  end
end
