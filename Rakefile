# encoding: utf-8

require 'rake/clean'
require './lib/lingo/version'

__DIR__ = File.expand_path('..', __FILE__)

PACKAGE_NAME = 'lingo'
PACKAGE_PATH = File.join(__DIR__, 'pkg', "#{PACKAGE_NAME}-#{Lingo::VERSION}")

if RUBY_PLATFORM =~ /msdos|mswin|djgpp|mingw|windows/i
  ZIP_COMMANDS = ['zip', '7z a']  # for hen's gem task
end

task :default => :spec
task :package => [:checkdoc, 'test:all', :clean]

begin
  require 'hen'

  Hen.lay! {{
    :rubyforge => {
      :package  => PACKAGE_NAME,
      :project  => PACKAGE_NAME,
      :rdoc_dir => nil
    },

    :gem => {
      :name              => PACKAGE_NAME,
      :version           => Lingo::VERSION,
      :summary           => 'The full-featured automatic indexing system',
      :authors           => ['John Vorhauer', 'Jens Wille'],
      :email             => ['john@vorhauer.de', 'jens.wille@uni-koeln.de'],
      :homepage          => 'http://lex-lingo.de',
      :files             => FileList['lib/**/*.rb', 'bin/*'].to_a,
      :extra_files       => FileList[
        '[A-Z]*', '.rspec', 'spec/**/*.rb',
        'lingo.rb', 'lingo{,-all,-call}.cfg', 'lingo.opt', 'doc/**/*',
        '{de,en}.lang', '{de,en}/{lingo-*,user-dic}.txt', 'txt/artikel{,-en}.txt',
        'info/gpl-hdr.txt', 'info/*.png', 'lir.cfg', 'txt/lir.txt', 'porter/*',
        'test.cfg', 'test/ts_*.rb', 'test/attendee/*.rb', '{de,en}/test_*.txt',
        'test/lir*.txt', 'test/mul.txt', 'test/ref/*', 'test/{de,en}/*'
      ].to_a,
      :dependencies      => [['ruby-nuggets', '>= 0.6.7']]
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem first. (#{err})"
end

CLEAN.include(
  'txt/*.{mul,non,seq,syn,ve?,csv}',
  'test/{test.*,text.non}',
  '{,test/}{de,en}/*.rev'
)

CLOBBER.include(
  '{,test/}{de,en}/store', 'doc' ,'pkg/*', PACKAGE_PATH + '.*'
)

task :checkdoc do
  docfile = File.join(__DIR__, 'doc', 'index.html')
  abort "Please run `rake doc' first." unless File.exists?(docfile)
end

desc 'Run ALL tests'
task 'test:all' => [:test, 'test:txt', 'test:lir']

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList.new('test/ts_*.rb', 'test/attendee/ts_*.rb')
end

desc 'Test against reference file (TXT)'
task 'test:txt' do
  test_ref('artikel', 'test')
end

desc 'Test against reference file (LIR)'
task 'test:lir' do
  test_ref('lir')
end

desc 'Run all tests on packaged distribution'
task 'test:remote' => [:package] do
  chdir(PACKAGE_PATH) { system('rake test:all') } || abort
end

def test_ref(name, cfg = name)
  require 'nuggets/util/ruby'

  require './lib/diff/lcs'
  require './lib/diff/lcs/ldiff'

  continue = 0

  Dir.chdir(__DIR__) {
    Process.ruby(*%W[lingo.rb -c #{cfg} txt/#{name}.txt]) { |_, _, *ios|
      ios.each { |io| io.read }
    }.success? or abort

    Dir["test/ref/#{name}.*"].each { |ref|
      puts "#{'#' * 60} #{org = ref.sub(/test\/ref/, 'txt')}"
      continue += Diff::LCS::Ldiff.run(ARGV.clear << org << ref)
    }
  }

  exit continue + 1 unless continue.zero?
end
