# Atom syndication example:
# Output upcoming events from a Google calendar feed

require 'open-uri'
require 'syndication/atom'
require 'syndication/google'

MY_CALENDAR = 'http://www.google.com/calendar/feeds/j4a3sad66efnj3rm5ou2fbnsbg@group.calendar.google.com/public/full'

parser = Syndication::Atom::Parser.new
feed = nil
open(MY_CALENDAR) {|file| 
  text = file.read
  feed = parser.parse(text)
}
t = feed.updated.strftime("%H:%I on %A %d %B")
puts "#{feed.title.txt}: #{feed.subtitle.txt} (updated #{t})"
for e in feed.entries
  if e.gd_when && e.gd_when.first
    t = e.gd_when.first.strftime("%d %b %y")
    puts "#{t}: #{e.title.txt}"
  end
end
