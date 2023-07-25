require 'lead/gitlab'

require 'dotenv'
Dotenv.load('.releaserc')

require 'gitlab'
Gitlab.configure do |config|
  config.endpoint = 'https://gitlab.infra.b-pl.pro/api/v4'
  config.private_token = ENV.fetch('GITLAB_TOKEN')
end

module Lead
  RSpec.describe Gitlab, development: true do
    let(:gitlab) { described_class.new 'cash/rgsb-product' }

    it 'works' do
      job = gitlab.tag_job('2.70.0-rc.4')
      puts "Wait for job #{job["web_url"]}"
      gitlab.wait_job!(job)
    end
  end
end
