# Copyright © mathew <meta@pobox.com> 2005.
# Licensed under the same terms as Ruby.
#
# $Header$

require 'syndication/tagsoup'
require 'test/unit'
require 'rexml/document'
require 'pp'

module Syndication

  # This class contains the unit tests for the Syndication module.
  class Tests < Test::Unit::TestCase

    def tag_start(x, pairs)
      @events << "tag_start(#{x.strip})"
      lst = nil
      if pairs
        for p in pairs
          if lst
            lst = lst + ","
          else
            lst = ""
          end
          lst << "#{p[0]}=#{p[1]}"
        end
        @events << "attrs(#{lst})"
      end
    end

    def tag_end(x)
      @events << "tag_end(#{x.strip})"
    end

    def text(x)
      @events << "text(#{x.strip})"
    end

    # Minimal test
    def test_tagsoup
      xml = <<-EOF
<a>
<b>one
<c></c></b>
<d arg1="alpha">two</d>
<e arg2='beta'>
three&lt;four&#99;&trade;
</e>
</a>
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
      @events = Array.new
      Syndication::TagSoup.parse_stream(xml, self)
      @tagsoup = @events
      @events = Array.new
      REXML::Document.parse_stream(xml, self)
      @rexml = @events
      puts "REXML\n-----"
      pp @rexml
      puts "\nTAGSOUP\n-------"
      pp @tagsoup
      errs = false
      for tsevt in @tagsoup
        rxevt = @rexml.shift
        if rxevt
          if tsevt.to_s != rxevt.to_s
            errs = true
            puts "TagSoup: [#{tsevt}]\nREXML: [#{rxevt}]"
          end
        end
      end
      assert(!errs, "TagSoup and REXML parse results didn't match")
    end

  end
end
