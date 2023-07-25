require 'tty-prompt'

module Lead
  module CLI
    module Commands
      module Git
        class Find < Dry::CLI::Command
          argument :subject, required: true, desc: 'Subject to find'

          def call(subject:, **)
            exec "git log --oneline --no-merges --grep #{subject}"
          end
        end

        class Compare < Dry::CLI::Command
          argument :subject, required: true, desc: 'Subject to find'

          attr_reader :subject, :prompt

          def call(subject:, **)
            @subject = subject
            @prompt = TTY::Prompt.new

            prompt.on(:keypress) do |event|
              if event.value == 'q'
                exit
              end
              if event.value == 'j'
                prompt.trigger(:keydown)
              end
              if event.value == 'k'
                prompt.trigger(:keyup)
              end
            end

            if choices_cached.empty?
              puts 'No commits found'
            else
              loop do
                hash = select_commit
                system "tig show #{hash}"
              end
            end
          rescue TTY::Reader::InputInterrupt
          end

          class Commit
            extend Dry::Initializer
            option :hash
            option :message
            option :state
          end

          def select_commit
            hash = prompt.select('Choose commit', choices_cached, per_page: 20, default: current_choice_index)

            set_current_choice hash

            hash
          end

          def set_current_choice(hash)
            @current_choice_index = choices_cached.find_index { |choice| choice[:value] == hash } + 1
          end

          def current_choice_index
            @current_choice_index || 1
          end

          def commits
            `git log --oneline --no-merges --left-right --graph --cherry-mark origin/master...HEAD --grep #{subject}`.split("\n").map do |line|
              m = line.match(/([<>=]) ([a-z0-9]{2,32}) (.*)/)
              Commit.new hash: m[2], message: m[3], state: m[1]
            end
          end

          def choices_cached
            @choices_cached ||= choices
          end

          def choices
            commits.map do |commit|
              { name: "#{commit.state} #{commit.hash} #{commit.message}", value: commit.hash }
            end
          end
        end
      end
    end
  end
end
