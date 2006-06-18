# Copyright © mathew <meta@pobox.com> 2005.
# Licensed under the same terms as Ruby.
#
# $Header: /var/cvs/syndication/syndication/test/rsstest.rb,v 1.4 2005/10/23 23:00:59 meta Exp $

require 'syndication/rss'
require 'test/unit'
require 'syndication/dublincore'
require 'syndication/content'
require 'syndication/podcast'

module Syndication

# This class contains the unit tests for the Syndication module.
class Tests < Test::Unit::TestCase

  # A set of minimal assertions that can be applied to every well-formed parsed
  # feed.
  def baseline_rss_assertions(feed)
    assert_not_nil(feed)
    assert_kind_of(Syndication::RSS::Feed, feed)
    loi = feed.items
    assert_not_nil(loi)
    assert_kind_of(Array, loi)
    assert(loi.length >= 1)
    assert_not_nil(loi[0])
    assert_not_nil(loi[0].description)
  end

  # Test a minimal well-formed RSS2.0 feed
  def test_rss2_wf_minimal
    xml = <<-EOF
    <rss version="2.0">
      <channel>
        <title>I like coffee</title>
        <link>http://www.coffeegeek.com/</link>
        <description>Hand over the latte &amp; nobody gets hurt.</description>
      </channel>
      <item>
        <description>A day without coffee is incomplete.</description>
      </item>
    </rss>
    EOF
    f = Syndication::RSS::Parser.new.parse(xml)
    baseline_rss_assertions(f)
    assert(f.channel.title == 'I like coffee')
    assert(f.channel.link == 'http://www.coffeegeek.com/')
    assert(f.channel.description == 'Hand over the latte & nobody gets hurt.')
    assert(f.items.first.description == 'A day without coffee is incomplete.')
    c = f.channel
    assert_not_nil(c)
    assert_kind_of(Syndication::RSS::Channel, c)
    assert_not_nil(c.title)
    assert_not_nil(c.link)
    assert_not_nil(c.description)
  end

  # Test a minimal well-formed RSS1.0 feed
  def test_rss1_wf_minimal
    xml = <<-EOF
    <?xml version="1.0"?>
    <rdf:RDF 
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns="http://purl.org/rss/1.0/"> 
    <channel rdf:about="http://www.otternet.com/">
      <title>OtterNet</title>
      <link>http://www.otternet.com/</link>
      <description>Otternet has pages &amp; pages of information about otters.</description>
    </channel>
    <item rdf:about="http://www.otternet.com/species/seaotter.htm">
      <title>The Sea Otter</title>
      <link>http://www.otternet.com/species/seaotter.htm</link>
      <description>The enticingly cute enhydra lontris.</description>
    </item>
    </rdf:RDF>
    EOF
    f = Syndication::RSS::Parser.new.parse(xml)
    baseline_rss_assertions(f)
    assert(f.channel.title == 'OtterNet')
    assert(f.channel.link == 'http://www.otternet.com/')
    assert(f.channel.description == 'Otternet has pages & pages of information about otters.')
    assert(f.items.first.title == 'The Sea Otter')
    assert(f.items.first.link == 'http://www.otternet.com/species/seaotter.htm')
    assert(f.items.first.description == 'The enticingly cute enhydra lontris.')
    c = f.channel
    assert_not_nil(c)
    assert_kind_of(Syndication::RSS::Channel, c)
    assert_not_nil(c.title)
    assert_not_nil(c.link)
    assert_not_nil(c.description)
  end

  # Test a well-formed RSS2 feed with every element possible and more than
  # one item
  def test_rss2_wf_full
    xml = <<-EOF
    <rss version="2">
      <channel>
        <title>Example Feed</title>
        <link>http://www.example.com/</link>
        <description>This is merely an example.</description>
        <language>en-us</language>
        <copyright>Copyright 2004 The Example Corporation.</copyright>
        <managingEditor>editor@example.com</managingEditor>
        <webMaster>webmaster@example.com</webMaster>
        <pubDate>Sat, 07 Sep 2002 00:01:02 EDT</pubDate>
        <lastBuildDate>Sat, 7 Sep 02 13:14:15 -0600</lastBuildDate>
        <category>examples</category>
        <category>boring</category>
        <generator>vim of course</generator>
        <docs>http://blogs.law.harvard.edu/tech/rss</docs>
        <cloud domain="rpc.sys.com" port="80" path="/RPC2" registerProcedure="pingMe" protocol="soap"/>
        <ttl>90</ttl>
        <image>
          <title>Example Inc</title>
          <url>http://www.example.com/images/logo.jpg</url>
          <link>http://www.example.com</link>
          <width>42</width>
          <height>23</height>
          <description>The Example Logo</description>
        </image>
        <rating>(PICS-1.1 "http://www.icra.org/ratingsv02.html" l gen true r (cz 1 lz 1 nz 1 oz 1 vz 1) "http://www.rsac.org/ratingsv01.html" l gen true r (n 0 s 0 v 0 l 0) "http://www.classify.org/safesurf/" l gen true r (SS~~000 1))</rating>
        <textInput>
          <title>Submit</title>
          <description>Enter keywords</description>
          <name>SearchKeywords</name>
          <link>http://www.example.com/cgi-bin/search.pl</link>
        </textInput>
        <skipHours>
          <hour>0</hour>
          <hour>23</hour>
        </skipHours>
        <skipDays>
          <day>Monday</day>
          <day>Sunday</day>
        </skipDays>
        <item>
          <title>Our stock price shot up</title>
          <link>http://www.example.com/news/2.html</link>
          <description>We were hyped in the press!</description>
        </item>
        <item>
          <title>A dull example of little value.</title>
          <link>http://www.example.com/news/1.html</link>
          <description>If this was any less interesting, it would be amazing.</description>
          <author>fred@example.com</author>
          <pubDate>Sat, 07 Sep 2002 00:01:02 EDT</pubDate>
          <category>dull</category>
          <category>amazingly</category>
          <comments>http://www.example.com/news/comments/1.html</comments>
          <enclosure url="http://www.example.com/mp3/advertisement.mp3" length="123987" type="audio/mpeg" />
          <guid>4asd98dgf9a74@example.com</guid>
          <source url="http://www.example.com/news.xml">Example News</source>
        </item>
      </channel>
    </rss>
    EOF
    f = Syndication::RSS::Parser.new.parse(xml)
    baseline_rss_assertions(f)
    for elem in %w(title link description language copyright managingeditor webmaster pubdate lastbuilddate category generator docs cloud ttl textinput rating skiphours skipdays)
      assert_not_nil(f.channel.send(elem), "feed.channel.#{elem} is nil, it shouldn't be")
      assert(f.channel.send(elem).to_s.length > 0)
    end
    items = f.items
    assert(items.length == 2)
    i = items.last
    for elem in %w(title link description author pubdate category comments enclosure guid source)
      assert_not_nil(i.send(elem), "feed.channel.item[1].#{elem} is nil, it shouldn't be")
    end
    cats = i.category
    assert(cats.length == 2)
    assert(cats.first == 'dull')
    assert(cats.last == 'amazingly')
    assert(f.channel.skiphours.length == 2)
    assert(f.channel.skiphours.first == 0)
    assert(f.channel.skiphours.last == 23)
    assert(f.channel.pubdate.kind_of?(DateTime))
    assert(f.channel.lastbuilddate.kind_of?(DateTime))
    assert(f.channel.pubdate.mday == 7)
    assert(f.channel.pubdate.month == 9)
    assert(f.channel.lastbuilddate.mday == 7)
    assert(f.channel.lastbuilddate.month == 9)
    c = f.channel
    assert_not_nil(c)
    assert_kind_of(Syndication::RSS::Channel, c)
    assert_not_nil(c.title)
    assert_not_nil(c.link)
    assert_not_nil(c.description)
  end

  # Test a well-formed RSS 1.0 feed with every element possible, more
  # than one item, and rdf:resource links in the channel
  def test_rss1_wf_full
    xml = <<-EOF
    <rdf:RDF
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns="http://purl.org/rss/1.0/">
      <channel>
        <title>Example Dot Org</title>
        <link>http://www.example.org</link>
        <description>the Example Organization web site</description>
        <image rdf:resource="http://www.example.org/images/logo.gif"/>
        <items>
          <rdf:Seq>
            <rdf:li resource="http://www.example.org/items/1"/>
            <rdf:li resource="http://www.example.org/items/2"/>
          </rdf:Seq>
        </items>
        <textinput rdf:resource="http://www.example.org/cgi-bin/input.pl"/>
      </channel>
      <textinput rdf:about="http://www.example.org/cgi-bin/input.pl">
        <title>Search example.org</title>
        <description>Search the example.org web site</description>
        <name>query</name>
        <link>http://www.example.org/cgi-bin/input.pl</link>
      </textinput>
      <image rdf:about="http://www.example.org/images/logo.gif">
        <title>Example.org logo</title>
        <link>http://www.example.org/</link>
        <url>http://www.example.org/images/logo.gif</url>
      </image>
      <item rdf:about="http://www.example.org/items/1">
        <title>Welcome</title>
        <link>http://www.example.org/items/1</link>
        <description>Welcome to our new news feed</description>
      </item>
      <item rdf:about="http://www.example.org/items/2">
        <title>New Status Update</title>
        <link>http://www.example.org/items/1</link>
        <description>News about the Example project</description>
      </item>
    </rdf:RDF>
    EOF
    f = Syndication::RSS::Parser.new.parse(xml)
    baseline_rss_assertions(f)
    for elem in %w(title link description textinput)
      assert_not_nil(f.channel.send(elem), "feed.channel.#{elem} is nil, it shouldn't be")
      assert(f.channel.send(elem).to_s.length > 0)
    end
    il = f.items
    assert(il.length == 2)
    i = il.last
    assert(i.link == 'http://www.example.org/items/1')
    assert(i.title == 'New Status Update')
    assert(i.description == 'News about the Example project')
    assert(f.textinput.title == 'Search example.org')
    f.channel.image.strip
    assert(f.image.url == 'http://www.example.org/images/logo.gif')
    c = f.channel
    assert_not_nil(c)
    assert_kind_of(Syndication::RSS::Channel, c)
    assert_not_nil(c.title)
    assert_not_nil(c.link)
    assert_not_nil(c.description)
  end

  # Test HTML encoded content in RSS 1.0 and namespace remapping
  def test_rss1_content
    xml = <<-EOF
    <?xml version="1.0"?>
    <rdf:RDF 
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:html="http://purl.org/rss/1.0/modules/content/"
      xmlns="http://purl.org/rss/1.0/"> 
    <channel rdf:about="http://www.otternet.com/">
      <title>OtterNet</title>
      <link>http://www.otternet.com/</link>
      <description>Otternet has dozens of pages of information about otters.</description>
      <content:encoded><![CDATA[<p><cite>OtterNet</cite> has <em>dozens</em> of pages of information about otters.</p>]]></content:encoded>
    </channel>
    <item rdf:about="http://www.otternet.com/species/seaotter.htm">
      <title>The Sea Otter</title>
      <link>http://www.otternet.com/species/seaotter.htm</link>
      <description>The enticingly cute enhydra lontris.</description>
      <html:encoded>The enticingly cute &lt;i&gt;enhydra lontris&lt;/i&gt;</html:encoded>
    </item>
    <item rdf:about="http://www.ruby-lang.org/">
      <title>Ruby</title>
      <link>http://www.ruby-lang.org/</link>
      <description>There's this language called Ruby, you may have heard of it.</description>
      <html:encoded>There's this language called &lt;strong&gt;Ruby&lt;/strong&gt;, you &lt;em&gt;may&lt;/em&gt; have heard of it.</html:encoded>
    </item>
    </rdf:RDF>
    EOF
    f = Syndication::RSS::Parser.new.parse(xml)
    baseline_rss_assertions(f)
    il = f.items
    assert(il.length == 2)
    i1 = il.first
    i2 = il.last
    assert_not_nil(i1.content_encoded, "content_encoded nil, shouldn't be")
    assert_not_nil(i2.content_encoded, "content_encoded nil, shouldn't be")
    assert(i1.content_encoded == 'The enticingly cute <i>enhydra lontris</i>')
    assert(i1.content_decoded == 'The enticingly cute <i>enhydra lontris</i>')
    assert(i2.content_decoded == "There's this language called <strong>Ruby</strong>, you <em>may</em> have heard of it.")
    c = f.channel
    assert(c.content_encoded == '<![CDATA[<p><cite>OtterNet</cite> has <em>dozens</em> of pages of information about otters.</p>]]>')
    assert(c.content_decoded == '<p><cite>OtterNet</cite> has <em>dozens</em> of pages of information about otters.</p>')
    assert_not_nil(c)
    assert_kind_of(Syndication::RSS::Channel, c)
    assert_not_nil(c.title)
    assert_not_nil(c.link)
    assert_not_nil(c.description)
  end

  # Test iTunes-specific duration parsing
  def test_itunes
    i = Syndication::RSS::Item.new(nil)
    i.itunes_duration = "12:34:56"
    assert(i.itunes_duration == 45296, "Duration computed incorrectly")
    i.itunes_duration = "5:43:21"
    assert(i.itunes_duration == 20601, "Duration computed incorrectly")
    i.itunes_duration = "20:01"
    assert(i.itunes_duration == 1201, "Duration computed incorrectly")
    i.itunes_duration = "3:52"
    assert(i.itunes_duration == 232, "Duration computed incorrectly")
  end

end

end
