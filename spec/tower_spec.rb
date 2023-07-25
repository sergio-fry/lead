require 'lead/tower'

module Lead
  RSpec.describe Tower, development: true do
    let(:tower) { described_class.new }

    it { puts tower.deploy(32, admin_git_version: 'develop')['url'] }
  end
end
