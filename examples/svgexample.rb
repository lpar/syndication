
# Example of parsing some SVG out of a feed

require 'open-uri'
require 'syndication/atom'
require 'pp'

parser = Syndication::Atom::Parser.new
feed = nil
open("svgexample.xml") {|file|
  text = file.read
  feed = parser.parse(text)
}
puts "#{feed.title.txt}"
for i in feed.entries
  puts "#{i.title.txt}: #{i.summary.txt}"
  content = i.content
  puts content.xml
end
