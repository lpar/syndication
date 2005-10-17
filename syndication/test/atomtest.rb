# Copyright © mathew <meta@pobox.com> 2005.
# Licensed under the same terms as Ruby.
# 
# $Header$

require 'syndication/atom'
require 'test/unit'

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
    def test_atom_minimal
      xml = <<-EOF
    <?xml version="1.0" encoding="utf-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <title>One good turn usually gets most of the blanket.</title>
      <updated>2005-08-20T21:14:38Z</updated>
      <id>urn:uuid:035d3aa3022c1b1b2a17e37ae2dcc376</id>
      <entry>
        <title>Quidquid latine dictum sit, altum viditur.</title>
        <link href="http://example.com/05/08/20/2114.html"/>
        <id>urn:uuid:89d96d76a99426264f6f1f520c1b93c2</id>
        <updated>2005-08-20T21:14:38Z</updated>
      </entry>
    </feed>
      EOF
      f = Syndication::Atom::Parser.new.parse(xml)
      baseline_assertions(f)
      assert(f.title.txt == 'One good turn usually gets most of the blanket.')
      assert(f.updated.strftime('%F %T') == '2005-08-20 21:14:38')
      assert(f.entries.length == 1, 'Wrong number of entries in feed')
      assert(f.id == 'urn:uuid:035d3aa3022c1b1b2a17e37ae2dcc376')
      e = f.entries[0]
      assert(e.title.txt == 'Quidquid latine dictum sit, altum viditur.')
      assert(e.links.length == 1, 'Wrong number of links in entry')
      l = e.links[0]
      assert(l.href == 'http://example.com/05/08/20/2114.html')
      assert(e.id == 'urn:uuid:89d96d76a99426264f6f1f520c1b93c2')
      assert(e.updated.strftime('%F %T') == '2005-08-20 21:14:38')
    end

    # Test a well-formed Atom feed with all possible elements
    def test_atom_wf_full
      xml = <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title type="text">It is the quality rather than the quantity that matters.</title>
  <updated>2005-08-20T21:43:44Z</updated>
  <id>urn:uuid:dc03a676cc5f04b9f0c728592270c8b7</id>
  <author>
    <name>mathew</name>
    <email>meta@pobox.com</email>
    <uri>http://www.pobox.com/~meta/</uri>
  </author>
  <category term="test"/>
  <category term="Ruby"/>
  <contributor>
    <name>Phil Space</name>
    <email>space@example.com</email>
  </contributor>
  <contributor>
    <name>Anne Example</name>
    <email>anne@example.com</email>
  </contributor>
  <generator uri="http://example.com/ruby/syndication" version="1.0">
    Ruby Syndication Library
  </generator>
  <icon>http://www.example.com/goatseicon.gif</icon>
  <link rel="self" type="application/ruby" href="file://atom.rb"/>
  <logo>http://www.example.com/goatse.jpg</logo>
  <rights>Copyright (c) meta@pobox.com 2005</rights>
  <subtitle type="xhtml">
    <div xmlns="http://www.w3.org/1999/xhtml">
      <p>This is <b>XHTML</b> content.</p>
    </div>
  </subtitle>
  <entry>
    <title>Cleanliness is next to impossible.</title>
    <summary type="xhtml">
      <xhtml:div xmlns:xhtml="http://www.w3.org/1999/xhtml">
        This is <xhtml:b>XHTML</xhtml:b> content.
      </xhtml:div>
    </summary> 
    <link href="http://example.com/05/08/20/2143.html"/>
    <id>urn:uuid:380b651e97c2e6ecc68eaa66c90939b6</id>
    <published>1978-03-12T10:22:11Z</published>
    <updated>2005-08-20T21:43:44Z</updated>
    <author>
      <name>Stu Dapples</name>
      <email>stu@example.com</email>
    </author>
    <category term="fortune"/>
    <category term="aphorism"/>
    <content type="text">
      Cleanliness of code is certainly next to impossible if you have to parse
      Atom feeds with all their features.
    </content>
    <contributor>
      <name>Ben Dover</name>
    </contributor>
    <contributor>
      <name>Eileen Dover</name>
    </contributor>
    <rights>This test entry is in the public domain.</rights>
  </entry>
  <entry>
    <title type="html">&lt;b>WE HAVE TACOS&lt;/b></title>
    <link href="http://www.pobox.com/~meta/"/>
    <id>urn:uuid:13be6c856fac98d9a7fd144b61dee06d</id>
    <updated>2004-12-23T21:22:23-06:00</updated>
    <source>
      <author><name>Rick O'Shea</name></author>
      <category term="example"/>
      <contributor><name>Hugh Cares</name></contributor>
      <generator uri="http://www.pobox.com/~meta/" version="1">
        Typed in by hand by some poor guy.
      </generator>
      <icon>http://www.example.com/icon2.png</icon>
      <id>urn:uuid:1234decafbad7890deadbeef5678304</id>
      <link rel="alternate" type="text/html"
        href="http://www.pobox.com/~meta/"/>
      <logo>http://www.example.com/logo.svg</logo>
      <rights>Some rights reserved, some not</rights>
      <title>More example stuff</title>
      <subtitle>MAKE IT STOP!</subtitle>
      <updated>2005-08-20T22:11-05:00</updated>
    </source>
  </entry>
</feed>
      EOF
      f = Syndication::Atom::Parser.new.parse(xml)
      baseline_assertions(f)
      assert(f.categories.length == 2)
      assert(f.contributors.length == 2)
      assert(f.contributors[0].name == 'Phil Space', "Feed#contributors name didn't match")
      assert(f.contributors[1].name == 'Anne Example', "Feed#contributors name didn't match")
      assert(f.categories[0].term = 'test', "Feed#categories didn't match")
      assert(f.categories[1].term = 'Ruby', "Feed#categories didn't match")
      assert(f.title.txt == 'It is the quality rather than the quantity that matters.')
      assert(f.updated == DateTime.parse('2005-08-20 21:43:44Z'), 'Feed#updated incorrectly parsed')
      assert(f.author.name == 'mathew')
      assert(f.author.email == 'meta@pobox.com')
      assert(f.author.uri == 'http://www.pobox.com/~meta/')
      assert(f.generator == 'Ruby Syndication Library')
      assert(f.icon == 'http://www.example.com/goatseicon.gif')
      assert(f.links.length == 1)
      assert(f.links[0].rel == 'self')
      assert(f.links[0].href == 'file://atom.rb')
      assert(f.links[0].type == 'application/ruby')
      assert(f.logo == 'http://www.example.com/goatse.jpg')
      assert(f.rights == 'Copyright (c) meta@pobox.com 2005')
      assert(f.subtitle.xhtml == '<p>This is <b>XHTML</b> content.</p>')
      assert(f.entries.length == 2)
      e1 = f.entries[0]
      assert(e1.summary.xhtml == 'This is <b>XHTML</b> content.')
      assert(e1.categories.length == 2)
      assert(e1.categories[0].term == 'fortune')
      assert(e1.categories[1].term == 'aphorism')
      e2 = f.entries[1]
      assert(e2.title.html == '<b>WE HAVE TACOS</b>')
      s = e2.source
      assert(s.kind_of?(Syndication::Atom::Feed))
      assert(s.title.txt == 'More example stuff')
      assert(s.updated == DateTime.parse('2005-08-20 22:11:00-0500'))
    end
  end
end
