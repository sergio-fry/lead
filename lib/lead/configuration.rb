require 'lead/git'
require 'lead/gitlab'
require 'lead/tower'
require 'lead/load_env'
require 'lead/console_ui'

module Lead
  class Configuration
    def gitlab
      return if ENV['GITLAB_TOKEN'].nil?

      ::Gitlab.configure do |config|
        config.endpoint = 'https://gitlab.infra.b-pl.pro/api/v4'
        config.private_token = ENV.fetch('GITLAB_TOKEN')
      end

      Gitlab.new ENV.fetch('GITLAB_PROJECT'), ui: ui
    end

    def deploy_rules
      JSON.parse(ENV.fetch('DEPLOY_RULES'))[git.branch]
    end

    def deployable?
      !deploy_rules.nil?
    end

    def git
      @git ||= Git.new Dir.pwd
    end

    def ui
      @ui ||= ConsoleUI.new
    end

    def tower
      @tower ||= Tower.new
    end
  end
end
