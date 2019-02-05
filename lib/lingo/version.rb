class Lingo

  module Version

    MAJOR = 1
    MINOR = 10
    TINY  = 2

    class << self

      # Returns array representation.
      def to_a
        [MAJOR, MINOR, TINY]
      end

      # Short-cut for version string.
      def to_s
        to_a.join('.')
      end

      def next_minor
        to_s[0, 3].next
      end

    end

  end

  VERSION = Version.to_s

end
