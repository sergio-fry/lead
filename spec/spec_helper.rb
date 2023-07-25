require 'bundler/setup'

require 'dotenv'
Dotenv.load('.env.test')

require 'byebug'
require 'lead'

Root = Pathname.new File.dirname(__dir__)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Disable long-running flaky specs by default. Require RSPEC_DEV_MODE = true
  unless ENV.fetch('RSPEC_DEV_MODE', 'false') == 'true'
    config.filter_run_excluding development: true
  end
end
