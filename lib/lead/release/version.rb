require 'semantic'

module Lead
  class Release
    class Version < Semantic::Version
      attr_reader :pre_type, :pre_number

      def initialize(*args)
        super

        unless release?
          m = pre.match(/([a-z]+)\.([0-9]+)/)
          raise ArgumentError, "Malformed pre '#{pre}'" if m.nil?

          @pre_number = m[2].to_i
          @pre_type = m[1]
        end
      end

      def pre_number=(val)
        @pre = "#{pre_type}.#{val}"
      end

      def release!
        new_version = clone
        new_version.pre = nil

        new_version
      end

      def pre_release!
        new_version = clone
        new_version.pre = 'rc.1'

        new_version
      end

      def alpha?
        return false if pre.nil?

        pre_type == 'alpha'
      end

      def candidate?
        return false if pre.nil?

        pre_type == 'rc'
      end

      def release?
        pre.nil?
      end

      def increment!(type)
        if type == :pre
          new_version = clone
          new_version.pre_number = pre_number + 1

          new_version
        else
          super
        end
      end

      def bump!(type = :alpha)
        new_version = clone

        if release?
          new_version.patch += 1
          new_version.pre = "#{type}.1"
        else
          new_version.pre_number += 1
        end

        new_version
      end
    end
  end
end
