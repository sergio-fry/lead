module Lead
  module CLI
    module Commands
      module Forward
        class CmdDaemon
          def initialize(cmd)
            @cmd = cmd
          end

          def spawn!
            Thread.new do
              while true
                `#{@cmd}`
              end
            end
          end
        end

        class Pods
          def find(name)

          end
        end

        
        class All < Dry::CLI::Command
          def call(**)
            daemon = CmdDaemon.new 'ssh  -N -L  127.0.0.1:6443:10.112.45.95:6443 elastic-server-1.cash-alfa-prod.cloud.b-pl.pro'

            daemon.spawn!

            sleep 10

          end
        end
      end
    end
  end
end
