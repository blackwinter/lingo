# encoding: utf-8

#--
###############################################################################
#                                                                             #
# Lingo -- A full-featured automatic indexing system                          #
#                                                                             #
# Copyright (C) 2005-2007 John Vorhauer                                       #
# Copyright (C) 2007-2013 John Vorhauer, Jens Wille                           #
#                                                                             #
# Lingo is free software; you can redistribute it and/or modify it under the  #
# terms of the GNU Affero General Public License as published by the Free     #
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# Lingo is distributed in the hope that it will be useful, but WITHOUT ANY    #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS   #
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for     #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU Affero General Public License    #
# along with Lingo. If not, see <http://www.gnu.org/licenses/>.               #
#                                                                             #
###############################################################################
#++

class Lingo

  class Attendee

    class Disambiguator2 < self

      STATS = BigramModel.new

      protected

      def init
        @load  = get_key('load', nil)
        @dump  = get_key('dump', nil)
        @learn = get_key('learn', !@load)
        @bound = get_key('bound', '.?!:;()[]{}').chars.to_a

        @start = %w[^]
        @close = %w[$]
        @token = []

        init_stats
      end

      def control(cmd, param)
        case cmd
          when STR_CMD_FILE
            state(@start)
            @token.clear
          when STR_CMD_EOF
            state(@start)
            @stats.dump(@dump) if @dump
            flush(@token.each { |obj| disambiguate(obj) })
        end
      end

      def process(obj)
        if @learn
          @token << obj

          case obj
            when Token then token(obj)
            when Word  then stat(attrs(obj))
          end
        else
          disambiguate(obj)
          forward(obj)
        end
      end

      private

      def init_stats(stats = self.class::STATS)
        @stats = stats
        @stats.load(@load) if @load
      end

      def disambiguate(obj)
        case obj
          when Token then token(obj)
          when Word
            (attrs = attrs(obj)).size < 2 ? state(attrs) : begin
              state([attr = rank(attrs).first])
              obj.lexicals.delete_if { |lex| lex.attr != attr }
            end
        end
      end

      def state(state)
        @state = state
      end

      def token(obj)
        state(@bound.include?(obj.form) ? @start : [obj.attr])
      end

      def attrs(obj)
        obj.identified? ? obj.attrs : [obj.attr]
      end

      def stat(attrs)
        @stats.stat(@state, state(attrs))
      end

      def rank(attrs)
        @stats.rank(@state.first, attrs)
      end

    end

    class Disambiguator3 < Disambiguator2

      STATS = TrigramModel.new

      private

      def state(state)
        @state = [state == @start ? state : @state[1], state]
        state
      end

      def stat(attrs)
        @stats.stat(@state[0], @state[1], state(attrs))
      end

      def rank(attrs)
        @stats.rank(@state[0][0], @state[1][0], attrs)
      end

    end

    class Disambiguator21 < Disambiguator2

      STATS = PeekingBigramModel.new

    end

    class Disambiguator1 < Disambiguator2

      STATS = UnigramModel.new

      private

      def state(state)
        @state = []
        state
      end

      def stat(attrs)
        @stats.stat(state(attrs))
      end

      def rank(attrs)
        @stats.rank(attrs)
      end

    end

    class DisambiguatorX < Disambiguator3

      private

      def init_stats
        super(SmoothingNGramModel.new(  # TODO: default weight?
          *%w[tri bi uni].map { |n| get_key("#{n}gram", 1).to_i }))
      end

    end

    Disambiguator = Disambiguator2

  end

end
