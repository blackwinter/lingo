# encoding: utf-8

require_relative 'test_helper'

class Lingo::Database

  alias_method :original_convert, :convert

  def convert(verbose = false)
    original_convert(verbose)
  end

end

class TestDatabase < LingoTestCase

  def setup
    @lingo = Lingo.new

    @singleword = <<-EOT
Wort1
Wort2
Wort2
juristische Personen
höher schneller weiter
höher schneller weiter größer
ganz großer und blöder quatsch
ganz großer und blöder mist
ganz großer und blöder schwach sinn
    EOT

    @keyvalue = <<-EOT
Wort1*Projektion1
Wort2*Projektion2
Wort3*Projektion3
Wort4*
Wort1*Projektion4
Wort1 * Projektion5
Mehr Wort Satz*Pro Jeck Zion 1
Mehr Wort Satz*Pro Jeck Zion 2
Albert Einstein*Einstein, Albert
    EOT

    @wordclass = <<-EOT
Wort1=Projektion1#h
Wort2=Projektion2#i
Wort3=Projektion3#e
Wort1=Projektion4 #e
Wort1=#s
Wort2=
    EOT
  end

  def test_singleword
    compare({
      'txt-format' => 'SingleWord'
    }, @singleword, {
      'wort1'                               => 'wort1#s',
      'wort2'                               => 'wort2#s',
      'juristische personen'                => 'juristische personen#s',
      'höher schneller weiter'              => 'höher schneller weiter#s',
      'höher schneller weiter größer'       => 'höher schneller weiter größer#s',
      'ganz großer und blöder quatsch'      => 'ganz großer und blöder quatsch#s',
      'ganz großer und blöder mist'         => 'ganz großer und blöder mist#s',
      'ganz großer und blöder schwach sinn' => 'ganz großer und blöder schwach sinn#s'
    })
  end

  def test_singleword_defwc
    compare({
      'txt-format' => 'SingleWord',
      'def-wc'     => '*'
    }, @singleword, {
      'wort1'                               => 'wort1#*',
      'wort2'                               => 'wort2#*',
      'juristische personen'                => 'juristische personen#*',
      'höher schneller weiter'              => 'höher schneller weiter#*',
      'höher schneller weiter größer'       => 'höher schneller weiter größer#*',
      'ganz großer und blöder quatsch'      => 'ganz großer und blöder quatsch#*',
      'ganz großer und blöder mist'         => 'ganz großer und blöder mist#*',
      'ganz großer und blöder schwach sinn' => 'ganz großer und blöder schwach sinn#*'
    })
  end

  def test_singleword_defmulwc
    compare({
      'txt-format' => 'SingleWord',
      'def-mul-wc' => 'm'
    }, @singleword, {
      'wort1'                               => 'wort1#s',
      'wort2'                               => 'wort2#s',
      'juristische personen'                => 'juristische personen#m',
      'höher schneller weiter'              => 'höher schneller weiter#m',
      'höher schneller weiter größer'       => 'höher schneller weiter größer#m',
      'ganz großer und blöder quatsch'      => 'ganz großer und blöder quatsch#m',
      'ganz großer und blöder mist'         => 'ganz großer und blöder mist#m',
      'ganz großer und blöder schwach sinn' => 'ganz großer und blöder schwach sinn#m'
    })
  end

  def test_singleword_uselex
    compare({
      'txt-format' => 'SingleWord',
      'use-lex'    => set_config('lex',
        'name'       => 'de/lingo-dic.txt',
        'txt-format' => 'WordClass',
        'separator'  => '='
      )
    }, @singleword, {
      'wort1'                           => 'wort1#s',
      'wort2'                           => 'wort2#s',
      'ganz groß und blöd mist'         => 'ganz großer und blöder mist#s',
      'juristisch person'               => 'juristische personen#s',
      'hoch schnell weit'               => '*4|höher schneller weiter#s',
      'ganz groß und blöd quatsch'      => 'ganz großer und blöder quatsch#s',
      'hoch schnell weit groß'          => 'höher schneller weiter größer#s',
      'ganz groß und blöd schwach sinn' => 'ganz großer und blöder schwach sinn#s',
      'ganz groß und'                   => '*5|*6'
    })
  end

  def test_singleword_crypt
    compare({
      'txt-format' => 'SingleWord',
      'crypt'      => true
    }, @singleword) { |db| hash = db.to_h; {
      'wort1'                               => 'wort1#s',
      'wort2'                               => 'wort2#s',
      'juristische personen'                => 'juristische personen#s',
      'höher schneller weiter'              => 'höher schneller weiter#s',
      'höher schneller weiter größer'       => 'höher schneller weiter größer#s',
      'ganz großer und blöder quatsch'      => 'ganz großer und blöder quatsch#s',
      'ganz großer und blöder mist'         => 'ganz großer und blöder mist#s',
      'ganz großer und blöder schwach sinn' => 'ganz großer und blöder schwach sinn#s'
    }.each { |key, val|
      assert_nil(hash[key])
      assert_equal([val], db[key])

      assert_nil(db[digest = db.crypter.digest(key)])
      assert_not_equal(key, digest)

      assert_instance_of(String, encrypted = hash[digest])
      assert_not_equal(val, encrypted)
    } }
  end

  def test_keyvalue
    compare({
      'txt-format' => 'KeyValue'
    }, @keyvalue, {
      'wort1'           => 'projektion1#?|projektion4#?|projektion5#?',
      'wort2'           => 'projektion2#?',
      'wort3'           => 'projektion3#?',
      'mehr wort satz'  => 'pro jeck zion 1#?|pro jeck zion 2#?',
      'albert einstein' => 'einstein, albert#?'
    })
  end

  def test_keyvalue_separator
    compare({
      'txt-format' => 'KeyValue',
      'separator'  => '*'
    }, @keyvalue, {
      'wort1'           => 'projektion1#?|projektion4#?|projektion5#?',
      'wort2'           => 'projektion2#?',
      'wort3'           => 'projektion3#?',
      'mehr wort satz'  => 'pro jeck zion 1#?|pro jeck zion 2#?',
      'albert einstein' => 'einstein, albert#?'
    })
  end

  def test_keyvalue_defwc
    compare({
      'txt-format' => 'KeyValue',
      'separator'  => '*',
      'def-wc'     => 's'
    }, @keyvalue, {
      'wort1'           => 'projektion1#s|projektion4#s|projektion5#s',
      'wort2'           => 'projektion2#s',
      'wort3'           => 'projektion3#s',
      'mehr wort satz'  => 'pro jeck zion 1#s|pro jeck zion 2#s',
      'albert einstein' => 'einstein, albert#s'
    })
  end

  def test_wordclass
    compare({
      'txt-format' => 'WordClass',
      'separator'  => '='
    }, %q{
      Wort1=Projektion1#h
      Wort2=Projektion2#i
      Wort3=Projektion3#e
      Wort1=Projektion4 #e
      Wort1=#s
      Wort2=
    }, {
      'wort1' => 'projektion1#h|projektion4#e',
      'wort2' => 'projektion2#i',
      'wort3' => 'projektion3#e'
    })
  end

  def test_multivalue
    compare({
      'txt-format' => 'MultiValue',
      'separator'  => ';'
    }, %q{
      Hasen;Nasen;Vasen;Rasen
      Gold;Edelmetall;Mehrwert
      Rasen;Gras;Grüne Fläche
      Rasen;Rennen;Wettrennen
    }, {
      '^0'           => 'hasen|nasen|rasen|vasen',
      '^1'           => 'edelmetall|gold|mehrwert',
      '^2'           => 'gras|grüne fläche|rasen',
      '^3'           => 'rasen|rennen|wettrennen',
      'hasen'        => '^0',
      'nasen'        => '^0',
      'rasen'        => '^0|^2|^3',
      'vasen'        => '^0',
      'edelmetall'   => '^1',
      'gold'         => '^1',
      'mehrwert'     => '^1',
      'gras'         => '^2',
      'grüne fläche' => '^2',
      'wettrennen'   => '^3',
      'rennen'       => '^3'
    })
  end

  def test_multikey
    compare({
      'txt-format' => 'MultiKey'
    }, %q{
      Hasen;Nasen;Vasen;Rasen
      Gold;Edelmetall;Mehrwert
    }, {
      'nasen'      => 'hasen',
      'vasen'      => 'hasen',
      'rasen'      => 'hasen',
      'edelmetall' => 'gold',
      'mehrwert'   => 'gold',
    })
  end

  def compare(config, input, output = nil)
    FileUtils.mkdir_p(File.dirname(TEST_FILE))
    File.open(TEST_FILE, 'w', encoding: Lingo::ENC) { |f| f.write(input) }

    Lingo::Database.open(set_config('tst', config.merge('name' => TEST_FILE)), @lingo) { |db|
      if block_given?
        yield db
      else
        assert_equal(output, db.to_h.tap { |store| store.delete(Lingo::Database::SYS_KEY) })
      end
    }
  ensure
    cleanup_store
  end

  def set_config(id, config)
    "_test_#{id}_".tap { |i| @lingo.config["language/dictionary/databases/#{i}"] = config }
  end

end
