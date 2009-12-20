
require 'open-uri'
require '~/WIP/syndication/trunk/syndication/lib/syndication/atom'
require 'pp'

parser = Syndication::Atom::Parser.new
feed = nil
open("http://blog.pastie.org/atom.xml") {|file|
  text = file.read
  feed = parser.parse(text)
}
puts "#{feed.title.txt}"
for i in feed.entries
  puts "#{i.title.txt}: #{i.summary.txt}"
  content = i.content
  puts content.xml
end
