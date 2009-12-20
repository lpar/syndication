
# RSS Syndication example:
#
# Output Yahoo news headlines, dated.

require 'open-uri'
require 'syndication/rss'

parser = Syndication::RSS::Parser.new
feed = nil
open("http://rss.news.yahoo.com/rss/topstories") {|file| 
  text = file.read
  feed = parser.parse(text)
}
chan = feed.channel
t = chan.lastbuilddate.strftime("%H:%I on %A %d %B")
puts "#{chan.title} at #{t}"
for i in feed.items
  t = i.pubdate.strftime("%d %b")
  puts "#{t}: #{i.title}"
end
