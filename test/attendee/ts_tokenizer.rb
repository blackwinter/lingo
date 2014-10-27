# encoding: utf-8

require_relative '../test_helper'

class TestAttendeeTokenizer < AttendeeTestCase

  def setup
    @wiki = [
      'Test [[Link|internal link]] and [http://example.com external link].',
      'Try __MAGIC__ with [[Multiline',
      'link (because we can)]].',
      '[[Category:cat1]]',
      'Link to [[:Category:cat2]].',
      '== Heading ==',
      '{{Template}}',
      'Function with {{#func|param|{{{var}}}}} and <nowiki>{{{var}}}</nowiki>!',
      '{{Multi',
      ' | line=1',
      ' | [[link]]',
      ' | {{{var}}}',
      '',
      '}}'
    ]

    @html = [
      'test <a>test</a> test',
      '<b>test <a>test</a></b>',
      'test <a test="test"><b>test</b></a>, test',
      '<a>test</a><b test="test">test</b><a>test</a>'
    ]
  end

  def test_basic
    meet({}, [
      'Dies ist ein Test.'
    ], [
      tk('Dies|WORD|0'),
      tk('ist|WORD|1'),
      tk('ein|WORD|2'),
      tk('Test|WORD|3'),
      tk('.|PUNC|4')
    ])
  end

  def test_complex
    meet({}, [
      '1964 www.vorhauer.de bzw. nasenbär, ()'
    ], [
      tk('1964|NUMS|0'),
      tk('www.vorhauer.de|URLS|1'),
      tk('bzw|WORD|2'),
      tk('.|PUNC|3'),
      tk('nasenbär|WORD|4'),
      tk(',|PUNC|5'),
      tk('(|OTHR|6'),
      tk(')|OTHR|7')
    ])
  end

  def test_wiki1
    meet({}, @wiki, [
      tk('Test|WORD|0'),
      tk('[|OTHR|1'),
      tk('[|OTHR|2'),
      tk('Link|WORD|3'),
      tk('||OTHR|4'),
      tk('internal|WORD|5'),
      tk('link|WORD|6'),
      tk(']|OTHR|7'),
      tk(']|OTHR|8'),
      tk('and|WORD|9'),
      tk('[|OTHR|10'),
      tk('http://example.com|URLS|11'),
      tk('external|WORD|12'),
      tk('link|WORD|13'),
      tk(']|OTHR|14'),
      tk('.|PUNC|15'),
      tk('Try|WORD|16'),
      tk('_|OTHR|17'),
      tk('_|OTHR|18'),
      tk('MAGIC|WORD|19'),
      tk('_|OTHR|20'),
      tk('_|OTHR|21'),
      tk('with|WORD|22'),
      tk('[|OTHR|23'),
      tk('[|OTHR|24'),
      tk('Multiline|WORD|25'),
      tk('link|WORD|26'),
      tk('(|OTHR|27'),
      tk('because|WORD|28'),
      tk('we|WORD|29'),
      tk('can|WORD|30'),
      tk(')|OTHR|31'),
      tk(']|OTHR|32'),
      tk(']|OTHR|33'),
      tk('.|PUNC|34'),
      tk('[|OTHR|35'),
      tk('[|OTHR|36'),
      tk('Category|WORD|37'),
      tk(':|PUNC|38'),
      tk('cat1|WORD|39'),
      tk(']|OTHR|40'),
      tk(']|OTHR|41'),
      tk('Link|WORD|42'),
      tk('to|WORD|43'),
      tk('[|OTHR|44'),
      tk('[|OTHR|45'),
      tk(':|PUNC|46'),
      tk('Category|WORD|47'),
      tk(':|PUNC|48'),
      tk('cat2|WORD|49'),
      tk(']|OTHR|50'),
      tk(']|OTHR|51'),
      tk('.|PUNC|52'),
      tk('=|OTHR|53'),
      tk('=|OTHR|54'),
      tk('Heading|WORD|55'),
      tk('=|OTHR|56'),
      tk('=|OTHR|57'),
      tk('{|OTHR|58'),
      tk('{|OTHR|59'),
      tk('Template|WORD|60'),
      tk('}|OTHR|61'),
      tk('}|OTHR|62'),
      tk('Function|WORD|63'),
      tk('with|WORD|64'),
      tk('{|OTHR|65'),
      tk('{|OTHR|66'),
      tk('#|OTHR|67'),
      tk('func|WORD|68'),
      tk('||OTHR|69'),
      tk('param|WORD|70'),
      tk('||OTHR|71'),
      tk('{|OTHR|72'),
      tk('{|OTHR|73'),
      tk('{|OTHR|74'),
      tk('var|WORD|75'),
      tk('}|OTHR|76'),
      tk('}|OTHR|77'),
      tk('}|OTHR|78'),
      tk('}|OTHR|79'),
      tk('}|OTHR|80'),
      tk('and|WORD|81'),
      tk('<|OTHR|82'),
      tk('nowiki|WORD|83'),
      tk('>|OTHR|84'),
      tk('{|OTHR|85'),
      tk('{|OTHR|86'),
      tk('{|OTHR|87'),
      tk('var|WORD|88'),
      tk('}|OTHR|89'),
      tk('}|OTHR|90'),
      tk('}|OTHR|91'),
      tk('<|OTHR|92'),
      tk('/|OTHR|93'),
      tk('nowiki|WORD|94'),
      tk('>|OTHR|95'),
      tk('!|PUNC|96'),
      tk('{|OTHR|97'),
      tk('{|OTHR|98'),
      tk('Multi|WORD|99'),
      tk('||OTHR|100'),
      tk('line|WORD|101'),
      tk('=|OTHR|102'),
      tk('1|NUMS|103'),
      tk('||OTHR|104'),
      tk('[|OTHR|105'),
      tk('[|OTHR|106'),
      tk('link|WORD|107'),
      tk(']|OTHR|108'),
      tk(']|OTHR|109'),
      tk('||OTHR|110'),
      tk('{|OTHR|111'),
      tk('{|OTHR|112'),
      tk('{|OTHR|113'),
      tk('var|WORD|114'),
      tk('}|OTHR|115'),
      tk('}|OTHR|116'),
      tk('}|OTHR|117'),
      tk('}|OTHR|118'),
      tk('}|OTHR|119')
    ])
  end

  def test_wiki2
    meet({ 'space' => true, 'tags' => true, 'wiki' => true }, @wiki, [
      tk('Test|WORD|0'),
      tk(' |SPAC|1'),
      tk('[[|WIKI|2'),
      tk('Link|internal link]]|WIKI|3'),
      tk(' |SPAC|4'),
      tk('and|WORD|5'),
      tk(' |SPAC|6'),
      tk('[http://|WIKI|7'),
      tk('example.com external link]|WIKI|8'),
      tk('.|PUNC|9'),
      tk('Try|WORD|10'),
      tk(' |SPAC|11'),
      tk('__MAGIC__|WIKI|12'),
      tk(' |SPAC|13'),
      tk('with|WORD|14'),
      tk(' |SPAC|15'),
      tk('[[|WIKI|16'),
      tk('Multiline|WIKI|17'),
      tk('link (because we can)]]|WIKI|18'),
      tk('.|PUNC|19'),
      tk('[[|WIKI|20'),
      tk('Category:cat1]]|WIKI|21'),
      tk('Link|WORD|22'),
      tk(' |SPAC|23'),
      tk('to|WORD|24'),
      tk(' |SPAC|25'),
      tk('[[|WIKI|26'),
      tk(':Category:cat2]]|WIKI|27'),
      tk('.|PUNC|28'),
      tk('== Heading ==|WIKI|29'),
      tk('{{|WIKI|30'),
      tk('Template}}|WIKI|31'),
      tk('Function|WORD|32'),
      tk(' |SPAC|33'),
      tk('with|WORD|34'),
      tk(' |SPAC|35'),
      tk('{{|WIKI|36'),
      tk('#func|param||WIKI|37'),
      tk('{{{|WIKI|38'),
      tk('var}}}|WIKI|39'),
      tk('}}|WIKI|40'),
      tk(' |SPAC|41'),
      tk('and|WORD|42'),
      tk(' |SPAC|43'),
      tk('<|HTML|44'),
      tk('nowiki>|HTML|45'),
      tk('{{{|WIKI|46'),
      tk('var}}}|WIKI|47'),
      tk('<|HTML|48'),
      tk('/nowiki>|HTML|49'),
      tk('!|PUNC|50'),
      tk('{{|WIKI|51'),
      tk('Multi|WIKI|52'),
      tk(' | line=1|WIKI|53'),
      tk(' | |WIKI|54'),
      tk('[[|WIKI|55'),
      tk('link]]|WIKI|56'),
      tk('|WIKI|57'),
      tk(' | |WIKI|58'),
      tk('{{{|WIKI|59'),
      tk('var}}}|WIKI|60'),
      tk('|WIKI|61'),
      tk('|WIKI|62'),
      tk('}}|WIKI|63')
    ])
  end

  def test_html1
    meet({ 'tags' => true }, @html, [
      tk('test|WORD|0'),
      tk('<|HTML|1'),
      tk('a>|HTML|2'),
      tk('test|WORD|3'),
      tk('<|HTML|4'),
      tk('/a>|HTML|5'),
      tk('test|WORD|6'),
      tk('<|HTML|7'),
      tk('b>|HTML|8'),
      tk('test|WORD|9'),
      tk('<|HTML|10'),
      tk('a>|HTML|11'),
      tk('test|WORD|12'),
      tk('<|HTML|13'),
      tk('/a>|HTML|14'),
      tk('<|HTML|15'),
      tk('/b>|HTML|16'),
      tk('test|WORD|17'),
      tk('<|HTML|18'),
      tk('a test="test">|HTML|19'),
      tk('<|HTML|20'),
      tk('b>|HTML|21'),
      tk('test|WORD|22'),
      tk('<|HTML|23'),
      tk('/b>|HTML|24'),
      tk('<|HTML|25'),
      tk('/a>|HTML|26'),
      tk(',|PUNC|27'),
      tk('test|WORD|28'),
      tk('<|HTML|29'),
      tk('a>|HTML|30'),
      tk('test|WORD|31'),
      tk('<|HTML|32'),
      tk('/a>|HTML|33'),
      tk('<|HTML|34'),
      tk('b test="test">|HTML|35'),
      tk('test|WORD|36'),
      tk('<|HTML|37'),
      tk('/b>|HTML|38'),
      tk('<|HTML|39'),
      tk('a>|HTML|40'),
      tk('test|WORD|41'),
      tk('<|HTML|42'),
      tk('/a>|HTML|43')
    ])
  end

  def test_html2
    meet({ 'skip-tags' => 'a' }, @html, [
      tk('test|WORD|0'),
      tk('<|SKIP|1'),
      tk('a>|SKIP|2'),
      tk('test|SKIP|3'),
      tk('<|SKIP|4'),
      tk('/a>|SKIP|5'),
      tk('test|WORD|6'),
      tk('<|HTML|7'),
      tk('b>|HTML|8'),
      tk('test|WORD|9'),
      tk('<|SKIP|10'),
      tk('a>|SKIP|11'),
      tk('test|SKIP|12'),
      tk('<|SKIP|13'),
      tk('/a>|SKIP|14'),
      tk('<|HTML|15'),
      tk('/b>|HTML|16'),
      tk('test|WORD|17'),
      tk('<|SKIP|18'),
      tk('a test="test">|SKIP|19'),
      tk('<|SKIP|20'),
      tk('b>|SKIP|21'),
      tk('test|SKIP|22'),
      tk('<|SKIP|23'),
      tk('/b>|SKIP|24'),
      tk('<|SKIP|25'),
      tk('/a>|SKIP|26'),
      tk(',|PUNC|27'),
      tk('test|WORD|28'),
      tk('<|SKIP|29'),
      tk('a>|SKIP|30'),
      tk('test|SKIP|31'),
      tk('<|SKIP|32'),
      tk('/a>|SKIP|33'),
      tk('<|HTML|34'),
      tk('b test="test">|HTML|35'),
      tk('test|WORD|36'),
      tk('<|HTML|37'),
      tk('/b>|HTML|38'),
      tk('<|SKIP|39'),
      tk('a>|SKIP|40'),
      tk('test|SKIP|41'),
      tk('<|SKIP|42'),
      tk('/a>|SKIP|43')
    ])
  end

end
