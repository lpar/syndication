# Example of reading a Podcast

require 'rubygems'
require 'syndication/rss'
require 'open-uri'

url = 'http://www.npr.org/rss/podcast.php?id=510093'

parser = Syndication::RSS::Parser.new

xml = nil

open(url) { |http|
  xml = http.read
}

feed = parser.parse(xml)

for i in feed.items
  puts i.enclosure.url
  puts i.enclosure.type
  puts i.enclosure.length
  puts
end
