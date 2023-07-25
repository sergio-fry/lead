require 'lead/release/named_version'

module Lead
  class Release
    RSpec.describe NamedVersion do
      def version(name)
        described_class.new name
      end

      it { expect(version('uat-1.2.3').major).to eq 1 }
    end
  end
end
