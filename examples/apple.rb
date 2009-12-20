# Example of using RSS 1.0 content module in RSS 2.0.
# (Naughty, but there you go.)

require 'rubygems'
require 'syndication/rss'
require 'syndication/content'
require 'open-uri'

url = 'http://docs.info.apple.com/rss/allproducts.rss'

parser = Syndication::RSS::Parser.new

xml = nil

open(url) { |http|
  xml = http.read
}

feed = parser.parse(xml)

for i in feed.items
  puts i.content_encoded
  puts
end
