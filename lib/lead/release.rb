require 'timeout'
require 'lead/release/named_version'

module Lead
  class Release
    extend Dry::Initializer
    option :ui
    option :git
    option :branch
    option :gitlab
    option :deploy_rules, default: -> { {} }
    option :tower, optional: true

    def major_name
      m = branch.match(/release\/(.+)/)

      return if m.nil?

      m[1]
    end

    def latest
      git.tags("#{major_name}*").map { |name| tag_version(name) }.compact.max
    end

    def next_version
      new_version = latest.bump!

      new_version = new_version.pre_release! if should_release?(new_version)

      new_version
    end

    def should_release?(version)
      release? && !version.candidate?
    end

    def tag_version(name)
      NamedVersion.new name
    rescue ArgumentError
      nil
    end

    def alpha?
      branch == 'master'
    end

    def release?
      !major_name.nil?
    end

    def bump!
      git.add_tag next_version.to_s
    end

    def deploy
      job = nil

      Timeout.timeout(20) do
        loop do
          job = gitlab.tag_job(latest.to_s)

          break unless job.nil?
        end
      end

      ui.message "Waiting job to build tag \"#{latest}\" #{job["web_url"]}"
      gitlab.wait_job!(job)

      (deploy_rules.is_a?(Array) ? deploy_rules : [deploy_rules]).each do |rules|
        deploy_with rules
      end
    end

    def deploy_with(rules)
      tower_job = tower.deploy(rules['project_id'], rules['tag_param'] => latest.to_s)

      ui.alert "Tower deploy \"#{latest}\" started at #{tower_job["url"]}"
      # ui.alert "Deployed #{gitlab.project} #{latest}!"
    end
  end
end
