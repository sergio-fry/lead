require 'lead/release/version'

module Lead
  class Release
    RSpec.describe Version do
      def version(name)
        described_class.new name
      end

      it { expect(version('1.2.3').major).to eq 1 }
      it { expect(version('1.2.3').minor).to eq 2 }
      it { expect(version('1.2.3').patch).to eq 3 }

      it { expect(version('1.2.3-alpha.1').major).to eq 1 }
      it { expect(version('1.2.3-alpha.1').minor).to eq 2 }
      it { expect(version('1.2.3-alpha.1').patch).to eq 3 }

      describe '#pre' do
        it { expect(version('1.2.3-alpha.1').pre).to eq 'alpha.1' }
      end

      describe '#pre_number' do
        it { expect(version('1.2.3-alpha.1').pre_number).to eq 1 }
        it { expect(version('1.2.3-alpha.2').pre_number).to eq 2 }
        it { expect(version('1.2.3-rc.2').pre_number).to eq 2 }
      end

      describe '#pre_type' do
        it { expect(version('1.2.3-alpha.1').pre_type).to eq 'alpha' }
        it { expect(version('1.2.3-rc.1').pre_type).to eq 'rc' }
      end

      describe '#alpha?' do
        it { expect(version('1.2.3')).not_to be_alpha }
        it { expect(version('1.2.3-alpha.1')).to be_alpha }
        it { expect(version('1.2.3-rc.1')).not_to be_alpha }
      end

      describe '#candidate?' do
        it { expect(version('1.2.3')).not_to be_candidate }
        it { expect(version('1.2.3-alpha.1')).not_to be_candidate }
        it { expect(version('1.2.3-rc.1')).to be_candidate }
      end

      describe '#release?' do
        it { expect(version('1.2.3')).to be_release }
        it { expect(version('1.2.3-alpha.1')).not_to be_release }
        it { expect(version('1.2.3-rc.1')).not_to be_release }
      end

      describe 'comparsion' do
        it { expect(version('1.0.1')).to be > version('1.0.0') }
        it { expect(version('1.0.1')).to be < version('1.1.0') }
        it { expect(version('1.0.0-rc.2')).to be > version('1.0.0-rc.1') }
        it { expect(version('1.0.0-rc.1')).to be > version('1.0.0-alpha.1') }
        it { expect(version('1.0.0')).to be > version('1.0.0-rc.1') }
        it { expect(version('1.1.0-alpha.1')).to be > version('1.0.0') }
      end

      describe '#increment' do
        it { expect(version('1.0.0').increment!(:major)).to eq version('2.0.0') }
        it { expect(version('1.0.0').increment!(:minor)).to eq version('1.1.0') }
        it { expect(version('1.0.0').increment!(:patch)).to eq version('1.0.1') }
        it { expect(version('1.0.0-alpha.1').increment!(:pre)).to eq version('1.0.0-alpha.2') }
        it { expect(version('1.0.0-rc.1').increment!(:pre)).to eq version('1.0.0-rc.2') }
      end

      describe '#release!' do
        it { expect(version('1.0.0-rc.1').release!).to eq version('1.0.0') }
      end

      describe '#pre_release!' do
        it { expect(version('1.0.0-alpha.2').pre_release!).to eq version('1.0.0-rc.1') }
      end

      describe '#bump' do
        it { expect(version('1.0.0-alpha.1').bump!).to eq version('1.0.0-alpha.2') }
        it { expect(version('1.0.0-pre.1').bump!).to eq version('1.0.0-pre.2') }
        it { expect(version('1.0.0').bump!(:alpha)).to eq version('1.0.1-alpha.1') }
        it { expect(version('1.0.0').bump!(:rc)).to eq version('1.0.1-rc.1') }
        it { expect(version('1.0.0').bump!).to eq version('1.0.1-alpha.1') }
      end
    end
  end
end
