require 'lead/git'
require 'git'

module Lead
  RSpec.describe Git do
    let(:path) { Root.join('/tmp/lead-specs/repo') }
    before { `mkdir -p #{path}` }
    before { ::Git.init(path.to_s) }
    before { add_commit }
    after { `rm -rf #{path}` }

    let(:git) { described_class.new path }

    describe 'branches' do
      it { expect(git.branch).to eq 'master' }

      context do
        before { git.checkout('release/1.0') }
        it { expect(git.branch).to eq 'release/1.0' }
      end
    end

    describe '#tags' do
      it { expect(git.tags).to eq [] }

      context do
        before { add_commit }
        before { git.add_tag('1.0.0') }

        it { expect(git.tags).to eq ['1.0.0'] }
        it { expect(git.tags('1.0*')).to eq ['1.0.0'] }
        it { expect(git.tags('2.0*')).to eq [] }
      end
    end

    def add_commit
      `touch #{path.join('file.txt')}`
      `cd #{path} && git add file.txt`
      `cd #{path} && git commit -m "test"`
    end
  end
end
