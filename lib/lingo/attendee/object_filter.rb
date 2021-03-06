# encoding: utf-8

#--
###############################################################################
#                                                                             #
# Lingo -- A full-featured automatic indexing system                          #
#                                                                             #
# Copyright (C) 2005-2007 John Vorhauer                                       #
# Copyright (C) 2007-2014 John Vorhauer, Jens Wille                           #
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

    #--
    # Der ObjectFilter ermöglicht es, beliebige Objekte aus dem Datenstrom herauszufiltern.
    # Um die gewünschten Objekte zu identifizieren, sind ein paar Ruby-Kenntnisse und das Wissen
    # um die Lingo Klassen notwendig. Hier sollen kurz die häufigsten Fälle angesprochen werden:
    #
    # Filtern nach einem bestimmten Typ, z.B. Token oder Word wird beispielsweise durch den Ausdruck
    # 'obj.kind_of?(Word)' ermöglicht. Token und Words haben jeweils ein Attribut +attr+.
    # Bei Token gibt +attr+ an, mit welcher Tokenizer-Regel das Token erkannt wurde. So können z.B.
    # alle numerischen Token mit dem Ausdruck 'obj.kind_of?(Token) && obj.attr=="NUMS"' identifiziert
    # werden. Wie bereits gezeigt, können Bedingungen durch logisches UND (&&) oder ODER (||) verknüpft werden.
    # Das Attribut +form+ kann genutzt werden, um auf den Text eines Objektes zuzugreifen, z.B.
    # 'obj.form=="John"'.
    #
    # === Mögliche Verlinkung
    # Erwartet:: Daten beliebigen Typs von allen Attendees
    # Erzeugt:: Daten, die der als Parameter übergebenen Bedingung entsprechen
    #
    # === Parameter
    # Kursiv dargestellte Parameter sind optional (ggf. mit Angabe der Voreinstellung).
    # Alle anderen Parameter müssen zwingend angegeben werden.
    # <b>in</b>:: siehe allgemeine Beschreibung des Attendee
    # <b>out</b>:: siehe allgemeine Beschreibung des Attendee
    # <b><i>objects</i></b>:: (Standard: true) Gibt einen Ruby-Ausdruck an, der, wenn der Ausdruck
    #                         als Wahr ausgewertet wird, das Objekt weiterleitet und ansonsten filtert.
    #
    # === Beispiele
    # Bei der Verarbeitung einer normalen Textdatei mit der Ablaufkonfiguration <tt>t1.cfg</tt>
    #   meeting:
    #     attendees:
    #       - text_reader:   { out: lines, files: '$(files)' }
    #       - tokenizer:     { in: lines, out: token }
    #       - word_searcher: { in: token, out: words, source: 'sys-dic' }
    #       - object_filter: { in: words, out: filtr, objects: 'obj.kind_of?(Word) && obj.lexicals.size>0 && obj.lexicals[0].attr==LA_NOUN' }
    #       - debugger:      { in: filtr, prompt: 'out>' }
    # ergibt die Ausgabe über den Debugger: <tt>lingo -c t1 test.txt</tt>
    #   out> *FILE('test.txt')
    #   out> <Indexierung = [(indexierung/s)]>
    #   out> <Indexierung = [(indexierung/s)]>
    #   out> *EOL('test.txt')
    #   out> *EOF('test.txt')
    #++

    class ObjectFilter < self

      def init
        @obj_eval = get_key('objects', 'true')
      end

      def control(*)
      end

      def process(obj)
        forward(obj) if eval(@obj_eval)
      end

    end

  end

end
