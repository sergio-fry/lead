require 'lead/release'
require 'lead/configuration'

module Lead
  module CLI
    module Commands
      module Release
        class Base < Dry::CLI::Command
          attr_reader :env, :release
          def initialize
            @env = Lead::Configuration.new
            @release = Lead::Release.new(
              git: env.git,
              branch: env.git.branch,
              gitlab: env.gitlab,
              ui: env.ui,
              deploy_rules: env.deploy_rules,
              tower: env.tower
            )

            env.ui.release = release
          end
        end
        class Bump < Base
          def call(*)
            release.bump!
            env.ui.message release.latest

            `git push origin HEAD`
            `git push --tags`

            release.deploy if env.deployable?
          end
        end
        class Current < Base
          def call(*)
            env.ui.message release.latest
          end
        end
        class Next < Base
          def call(*)
            env.ui.message release.next_version
          end
        end
      end
    end
  end
end
