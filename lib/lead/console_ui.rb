require 'net/http'

module Lead
  class ConsoleUI
    attr_accessor :release

    def message(msg)
      puts msg
    end

    def open(target)
      `open #{target}`
    end

    def progress_tick
      print '.'
    end

    def alert(msg)
      puts msg
      web_hook_message(msg)
    end

    private

    def web_hook_message(msg)
      prefix = "[#{ENV.fetch("GITLAB_PROJECT")}]"

      uri = URI(ENV.fetch('WEBHOOK_URL'))
      Net::HTTP.post_form(uri, payload: { channel: '#su-notifications', text: "#{prefix} #{msg}", authed_users: ['@udalov'] }.to_json)
    end
  end
end
