# Copyright © mathew <meta@pobox.com> 2005.
# Licensed under the same terms as Ruby.

require 'syndication/atom'
require 'syndication/google'
require 'test/unit'
require 'pp'

module Syndication

  # This class contains the unit tests for the Syndication module.
  class Tests < Test::Unit::TestCase

    # A set of minimal assertions that can be applied to every well-formed parsed
    # feed.
    def baseline_assertions(feed)
      assert_not_nil(feed, 'Parser returned nil')
      assert_kind_of(Syndication::Atom::Feed, feed)
      assert_not_nil(feed.title, 'Feed#title was nil')
      assert_not_nil(feed.id, 'Feed#id was nil')
      assert_not_nil(feed.updated, 'Feed#updated was nil')
      assert_kind_of(DateTime, feed.updated)
      assert(feed.entries.length > 0, 'No entries in feed')
      for entry in feed.entries
        assert_not_nil(entry.title, 'Entry#title was nil')
        assert_not_nil(entry.id, 'Entry#id was nil')
        assert(entry.links.length > 0, 'No links in entry')
        assert_not_nil(entry.links[0], 'Entry#links[0] was nil')
        assert_not_nil(entry.updated, 'Entry#updated was nil')
        assert_kind_of(DateTime, entry.updated)
      end
    end

    # Minimal test
    def test_atom_google
      xml = <<EOF
<feed xmlns='http://www.w3.org/2005/Atom'
    xmlns:gd='http://schemas.google.com/g/2005'>
  <id>http://www.google.com/calendar/feeds/jo@gmail.com/private-magicCookie/full</id>
  <updated>2006-03-29T07:35:59.000Z</updated>
  <title type='text'>Jo March</title>
  <subtitle type='text'>This is my main calendar.</subtitle>
  <link rel='http://schemas.google.com/g/2005#feed' type='application/atom+xml'
    href='http://www.google.com/calendar/feeds/jo@gmail.com/private-magicCookie/full'></link>
  <link rel='self' type='application/atom+xml'
    href='http://www.google.com/calendar/feeds/jo@gmail.com/private-magicCookie/full'></link>
  <author>
    <name>Jo March</name>
    <email>jo@gmail.com</email>
  </author>
  <generator version='1.0' uri='http://www.google.com/calendar/'>CL2</generator>
  <gd:where valueString='California'></gd:where>
  <entry>
    <id>http://www.google.com/calendar/feeds/jo@gmail.com/private-magicCookie/full/entryID</id>
    <published>2006-03-30T22:00:00.000Z</published>
    <updated>2006-03-28T05:47:31.000Z</updated>
    <category scheme='http://schemas.google.com/g/2005#kind'
      term='http://schemas.google.com/g/2005#event'></category>
    <title type='text'>Lunch with Darcy</title>
    <content type='text'>Lunch to discuss future plans.</content>
    <link rel='alternate' type='text/html'
      href='http://www.google.com/calendar/event?eid=aTJxcnNqbW9tcTJnaTE5cnMybmEwaW04bXMgbWFyY2guam9AZ21haWwuY29t'
      title='alternate'></link>
    <link rel='self' type='application/atom+xml'
      href='http://www.google.com/calendar/feeds/jo@gmail.com/private-magicCookie/full/entryID'></link>
    <author>
      <name>Jo March</name>
      <email>jo@gmail.com</email>
    </author>
    <gd:transparency
      value='http://schemas.google.com/g/2005#event.opaque'></gd:transparency>
    <gd:eventStatus
      value='http://schemas.google.com/g/2005#event.confirmed'></gd:eventStatus>
    <gd:comments>
      <gd:feedLink
        href='http://www.google.com/calendar/feeds/jo@gmail.com/private-magicCookie/full/entryID/comments/'></gd:feedLink>
    </gd:comments>
    <gd:when startTime='2006-03-30T22:00:00.000Z'
      endTime='2006-03-30T23:00:00.000Z'></gd:when>
    <gd:where></gd:where>
  </entry>
</feed>
EOF
      f = Syndication::Atom::Parser.new.parse(xml)
      baseline_assertions(f)
      entry = f.entries.first
      assert entry.gd_when[0].to_s == "2006-03-30T22:00:00+00:00"
      assert entry.gd_when[1].to_s == "2006-03-30T23:00:00+00:00"
    end

  end
end
