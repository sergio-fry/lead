require_relative 'version'

module Lead
  class Release
    class NamedVersion
      attr_reader :version

      def initialize(version_with_name)
        @version_with_name = version_with_name
        @version = Version.new(version_without_name)
      end

      def major
        version.major
      end

      def named?
        !name.nil?
      end

      def version_without_name
        m = @version_with_name.match(/^[a-z]+-(.+)/)

        if m.nil?
          @version_with_name
        else
          m[1]
        end
      end

      def name
        m = @version_with_name.match(/^([a-z]+)-.+/)

        if m.nil?
          nil
        else
          m[1]
        end
      end

      def bump!
        if named?
          self.class.new("#{name}-#{version.bump!}")
        else
          version.bump!
        end
      end

      def candidate?
        version.candidate?
      end

      def to_s
        [name, version.to_s].compact.join('-')
      end

      def <=>(other)
        version <=> other.version
      end
    end
  end
end
