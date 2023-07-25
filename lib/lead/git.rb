require 'git'
require 'logger'

module Lead
  class Git
    extend Dry::Initializer
    param :path

    attr_reader :git

    def initialize(*args)
      super
      @git = ::Git.open path, logger: Logger.new($stdout)
    end

    def branch
      git.current_branch
    end

    def add_tag(name)
      git.add_tag name
    end

    def checkout(name)
      git.branch(name).checkout
    end

    def tags(pattern = '*')
      `cd #{path} && git tag -l "#{pattern}"`.split
    end
  end
end
