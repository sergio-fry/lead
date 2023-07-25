require 'lead/release'

module Lead
  RSpec.describe Release do
    let(:release) do
      described_class.new(
        git: git,
        branch: git.branch,
        ui: ui,
        gitlab: gitlab,
        deploy_rules: deploy_rules,
        tower: tower
      )
    end

    let(:tower) { double(:tower) }
    let(:deploy_rules) { {} }
    let(:git) { double(:git, branch: branch, tags: tags) }
    let(:gitlab) { double(:gitlab) }
    let(:branch) { 'release/2.70' }
    let(:tags) { ['2.70.0'] }
    let(:ui) { double(:ui) }

    describe '#major_name' do
      subject { release.major_name }
      it { is_expected.to eq '2.70' }
    end

    describe '#latest' do
      subject { release.latest ? release.latest.to_s : nil }

      context do
        let(:tags) { ['2.70.0'] }
        it { is_expected.to eq '2.70.0' }
      end
      context do
        let(:tags) { ['2.70.0', 'malformed', '1.2.3-very-alfa'] }
        it { is_expected.to eq '2.70.0' }
      end
      context do
        let(:tags) { ['2.70.1'] }
        it { is_expected.to eq '2.70.1' }
      end
      context do
        let(:tags) { ['2.70.0', '2.70.2', '2.70.1'] }
        it { is_expected.to eq '2.70.2' }
      end
      context do
        let(:tags) { [] }
        it { is_expected.to be_nil }
      end

      context do
        let(:branch) { 'release/uat' }

        context do
          let(:tags) { [] }
          it { is_expected.to eq nil }
        end

        context do
          let(:tags) { ['uat-1.0.0-rc.1', 'uat-1.0.0-rc.2'] }
          it { is_expected.to eq 'uat-1.0.0-rc.2' }
        end
      end
    end

    describe '#release?' do
      context do
        let(:branch) { 'release/1.0' }
        it { expect(release).to be_release }
        it { expect(release).not_to be_alpha }
      end

      context do
        let(:branch) { 'master' }
        it { expect(release).not_to be_release }
        it { expect(release).to be_alpha }
      end

      context do
        let(:branch) { 'TASK-123' }
        it { expect(release).not_to be_release }
        it { expect(release).not_to be_alpha }
      end
    end

    describe '#bump!' do
      before { allow(release).to receive(:latest).and_return(version) }

      context do
        before { allow(release).to receive(:release?).and_return(true) }

        context do
          let(:version) { Release::NamedVersion.new('2.70.0') }
          it { expect_next_version_to_eq '2.70.1-rc.1' }
        end
        context do
          let(:version) { Release::NamedVersion.new('2.71.0-rc.1') }
          it { expect_next_version_to_eq '2.71.0-rc.2' }
        end
      end

      def expect_next_version_to_eq(name)
        expect(git).to receive(:add_tag).with(name)
        release.bump!
      end
    end

    describe '#deploy' do
      let(:branch) { 'release/2.70' }
      let(:tags) { ['2.70.0'] }
      let(:gitlab_job) { { 'web_url' => 'http://gitlab/job/1' } }
      let(:deploy_rules) { { 'project_id' => 1, 'tag_param' => 'git_version' } }
      let(:tower) { double(:tower) }
      let(:tower_job) { { 'url' => 'http://tower/job/1' } }
      let(:gitlab) { double(:gitlab, project: 'cash/rgsb-product') }

      before { expect(gitlab).to receive(:tag_job).with('2.70.0').and_return(gitlab_job) }
      before { expect(gitlab).to receive(:wait_job!).with(gitlab_job) }
      before { expect(ui).to receive(:message).with('Waiting job to build tag "2.70.0" http://gitlab/job/1') }
      before { expect(ui).to receive(:alert).with('Tower deploy "2.70.0" started at http://tower/job/1') }
      # before { expect(ui).to receive(:alert).with("Deployed \"2.70.0\"!") }
      before { expect(tower).to receive(:deploy).with(1, { 'git_version' => '2.70.0' }).and_return(tower_job) }

      it do
        release.deploy
      end
    end
  end
end
