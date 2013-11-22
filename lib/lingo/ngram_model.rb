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

  class NGramModel < Hash

    class << self

      def load(file, type = self)
        ensure_type(model = load_file(file), type) { model }
      end

      def dump(model, file, type = self)
        ensure_type(model, type) { dump_file(model, file) }
      end

      private

      def ensure_type(model, type)
        model.is_a?(type) ? yield :
          raise(TypeError, "#{type} expected, got #{model.class}")
      end

      def load_file(file)
        File.open(file, 'rb', encoding: ENC) { |f| Marshal.load(f) }
      end

      def dump_file(model, file)
        File.open(file, 'wb', encoding: ENC) { |f| Marshal.dump(model, f) }
      end

    end

    def stat(ary, *rest)
      ary.product(*rest) { |keys| key = keys.pop; _store(*keys)[key] += 1 }
    end

    def rank(*ary)
      attrs, hash = _prepare_rank(*ary)
      _rank(attrs) { |attr| hash[attr] }
    end

    def load(file)
      replace(self.class.load(file))
    end

    def dump(file)
      self.class.dump(self, file)
    end

    def hash
      [self.class, super].hash
    end

    def eql?(other)
      self.class.equal?(other.class) && super
    end

    alias_method :==, :eql?

    private

    def _store(*keys)
      key = keys.pop or return self
      keys.inject(self) { |h, k| h[k] ||= {} }[key] ||= Hash.new(0)
    end

    def _fetch(*keys)
      key = keys.pop or return self
      keys.inject(self) { |h, k| h[k] || {} }[key] || Hash.new(0)
    end

    def _prepare_rank(*ary)
      freeze  # XXX
      [ary.pop, _fetch(*ary)]
    end

    def _rank(attrs)
      attrs.map.with_index { |attr, index|
        [-yield(attr), index, attr]
      }.sort!.map! { |_, _, attr| attr }
    end

    def _sum(ary, &block)
      (block ? ary.flat_map(&block) : ary).inject(0, :+)
    end

  end

  class UnigramModel < NGramModel

    def initialize(*)
      super
      self.default = 0
    end

    def stat(attrs)
      super
    end

    #         ????
    #    attr  O₁₁
    #   ¬attr  O₂₁
    def rank(attrs)
      super
    end

  end

  class BigramModel < NGramModel

    def stat(preds, attrs)
      super
    end

    # Chi-squared (+O+ = observed frequency, +N+ = sample size):
    #
    #         pred ¬pred
    #    attr  O₁₁   O₁₂
    #   ¬attr  O₂₁   O₂₂
    #
    #             N * (O₁₁ * O₂₂ - O₁₂ * O₂₁) ** 2
    #   -----------------------------------------------------
    #   (O₁₁ + O₁₂) * (O₁₁ + O₂₁) * (O₁₂ + O₂₂) * (O₂₁ + O₂₂)
    def rank(pred, attrs)
      #return super  # XXX

      v, _, w = values, *_prepare_rank(pred, attrs)

      s0 = _sum(v) { |h| h.values }  # O₁₁ + O₁₂ + O₂₁ + O₂₂
      s1 = _sum(w.values)            # O₁₁ + O₂₁

      s2 = s0 - s1  # O₁₂ + O₂₂
      p1 = s1 * s2  # (O₁₁ + O₂₁) * (O₁₂ + O₂₂)

      p1.zero? ? attrs : _rank(attrs) { |attr|
        s3 = _sum(v) { |h| h[attr] }  # O₁₁ + O₁₂

        c1 = w[attr]  # O₁₁
        c2 = s3 - c1  # O₁₂
        c3 = s1 - c1  # O₂₁
        c4 = s2 - c2  # O₂₂

        div = (c1 * c4 - c2 * c3) ** 2  # * n
        num = s3 * p1 * (s0 - s3)

        num.zero? ? 0 : div.to_f / num
        #Statsample::Test::ChiSquare::WithMatrix.new(Matrix[[c1, c2], [c3, c4]]).chi_square.to_f
      }
    end

  end

  class TrigramModel < NGramModel

    def stat(preds1, preds2, attrs)
      super
    end

    # XXX ???
    #
    #         pred1 pred2 ¬pred1 ¬pred2
    #    attr  O₁₁   O₁₂    O₁₃    O₁₄
    #   ¬attr  O₂₁   O₂₂    O₂₃    O₂₄
    def rank(pred1, pred2, attrs)
      super
    end

  end

  class PeekingUnigramModel < NGramModel

    def stat(attrs, succs)
      super
    end

    def rank(attrs, succs)
      raise NotImplementedError
    end

  end

  class PeekingBigramModel < NGramModel

    def stat(preds, attrs, succs)
      super  # ???
    end

    def rank(pred, attrs, succs)
      raise NotImplementedError
    end

  end

  class SmoothingNGramModel

    MODELS = [TrigramModel, BigramModel, UnigramModel]

    def initialize(*weights)
      @models = {}
      MODELS.each_with_index { |k, i| @models[k.new] = weights[i] }
    end

    def stat(*args)
      @models.each { |model, weight|
        model.stat(*args) if weight
        args.shift
      }
    end

    def rank(*args)
      # TODO: smoothing!
      @models.map { |model, weight|
        if weight
          r = model.rank(*args)
          args.shift
          r
        end
      }.compact.first
    end

    def load(file)
      @models.replace(NGramModel.load(file, Hash))
    end

    def dump(file)
      NGramModel.dump(@models, file, Hash)
    end

  end

end
