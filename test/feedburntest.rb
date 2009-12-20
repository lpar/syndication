# Copyright © mathew <meta@pobox.com> 2006.
# Licensed under the same terms as Ruby.

require 'syndication/rss'
require 'test/unit'
require 'syndication/dublincore'
require 'syndication/content'
require 'syndication/podcast'
require 'syndication/feedburner'

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

    def test_feedburner
      xml = <<-EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <?xml-stylesheet href="http://feeds.sfgate.com/~d/styles/rss2full.xsl" type="text/xsl" media="screen"?>
    <?xml-stylesheet href="http://feeds.sfgate.com/~d/styles/itemcontent.css" type="text/css" media="screen"?>
    <rss xmlns:feedburner="http://rssnamespace.org/feedburner/ext/1.0" version="2.0">
    <channel>
        <title>SFGate: Top News Stories</title>
        <link>http://www.sfgate.com/</link>
        <description>Top news stories. From SFGate.com: the Bay Area's home page, online home of the San Francisco Chronicle and much more.</description>
        <language>en-us</language>
        <copyright>Copyright 2006 Hearst Communications, Inc.</copyright>
        <managingEditor>ed@sfgate.com (SFGate Editorial staff)</managingEditor>
        <webMaster>support@sfgate.com (SFGate technical support)</webMaster>
        <lastBuildDate>Sun, 09 Jul 2006 14:21:10 PDT</lastBuildDate>
        <category>News</category>
        <category>Newspapers</category>
        <category>San Francisco</category>
        <category>San Francisco Bay Area</category>
        <docs>http://blogs.law.harvard.edu/tech/rss</docs>
        <image>
            <url>http://www.sfgate.com/templates/types/syndication/pages/rss/graphics/sfgate_logo.png</url>
            <title>SFGate: Top News Stories</title>
            <link>http://www.sfgate.com/</link>
        </image>
        <atom10:link xmlns:atom10="http://www.w3.org/2005/Atom" rel="self" href="http://www.sfgate.com/rss/feeds/news.xml" type="application/rss+xml" /><feedburner:browserFriendly>This is an RSS feed, but with the headlines made visible. Choose one of the buttons to add this feed to your favorite RSS reader.</feedburner:browserFriendly>
        <item>
            <title><![CDATA[Italy Beats France for 4th World Cup Title]]></title>
            <link>http://feeds.sfgate.com/sfgate/rss/feeds/news?m=4300</link>
            <description>Italy let France do nearly anything it wanted Sunday, except win the World Cup. That belongs to the Azzurri, 5-3 in a shootout after a 1-1 draw. Outplayed for an hour and into extra time, the Italians won it after French captain Zinedine Zidane was...&lt;img src="http://feeds.sfgate.com/sfgate/rss/feeds/news?g=4300"/&gt;</description>
            <author><![CDATA[By BARRY WILNER, AP Sports Writer]]></author>
            <pubDate>Sun, 09 Jul 2006 14:14:59 PDT</pubDate>

            <guid isPermaLink="false">/n/a/2006/07/09/sports/s134544D82.DTL</guid>
            <feedburner:origLink>http://www.sfgate.com/cgi-bin/article.cgi?f=/n/a/2006/07/09/sports/s134544D82.DTL&amp;feed=rss.news</feedburner:origLink>
            </item>        
    </channel>
    </rss>
    EOF
      f = Syndication::RSS::Parser.new.parse(xml)
      il = f.items
      assert_not_nil(il)
      assert(il.length == 1)
      i = il.first
      assert_not_nil(i.feedburner_origlink)
      assert(i.feedburner_origlink == "http://www.sfgate.com/cgi-bin/article.cgi?f=/n/a/2006/07/09/sports/s134544D82.DTL&feed=rss.news")
    end

  end

end
