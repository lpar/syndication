# This module provides classes and methods for parsing RSS web syndication 
# feeds.
#
# Copyright © mathew <meta@pobox.com> 2005.
# Licensed under the same terms as Ruby.
#
# $Header$

require 'uri'
require 'rexml/parsers/streamparser'
require 'rexml/streamlistener'
require 'rexml/document'
require 'date'
require 'syndication/common'

module Syndication
  class Container

    # This method is used by objects in RSS feeds that accept 
    # <category> elements
    def store_category(cat)
      if cat.kind_of?(String)
        if !@category
          @category = Array.new
        end
        @category << cat
      end
    end
  end

  # RSS is a method of syndicating web site content.
  #
  # There are nine different versions of RSS; see
  # <URL:http://diveintomark.org/archives/2004/02/04/incompatible-rss>
  #
  # This code attempts to parse all of them, and provide the same API via
  # the same data model regardless of the particular flavor of RSS fed in.
  #
  # One thing to be aware of is that RSS 0.9x and 2.0x have no mechanism for 
  # indicating the type of text in a description, whether plain text or HTML.
  # As a result, this library leaves it to you to write code to 'sniff' 
  # the data returned and decide whether you think it looks like text or HTML.
  #
  # RSS 1.0 solves the problem via the content module, which is supported
  # via Syndication::Content. Atom solves the problem too.
module RSS

  # Represents an individual story or entry in an RSS feed.
  class Item < Container
    # The title of the item as a String.
    attr_accessor :title 
    # The URL of the item as a String.
    attr_accessor :link 
    # A textual description of the item as a String.
    attr_accessor :description 
    # E-mail address of item author.
    attr_accessor :author 
    # One or more categories for the item, as an Array of Strings.
    attr_reader :category 
    alias category= store_category
    # URL for feedback on this item as a String.
    attr_accessor :comments 
    # A media object attached to the item, as a Syndication::Enclosure.
    attr_accessor :enclosure 
    # A globally unique identifier for this item, a String.
    attr_accessor :guid 
    # The publication date for this item. Accepts anything DateTime can
    # parse, which includes RFC822-style dates as specified by the RSS
    # standards.
    attr_writer :pubdate 
    # An RSS channel this item was copied from, used to give credit for
    # copied links. A URL String.
    attr_accessor :source 

    # Publication date as a DateTime if possible; if it won't parse,
    # returns the original string.
    def pubdate
      parse_date(@pubdate)
    end
  end

  # Used to represent graphical images provided in an RSS feed, with the 
  # intent that they be used to represent the channel in a graphical user 
  # interface, or on a web page.
  #
  # Typically found via Syndication::Channel#image
  class Image < Container
    # URL of image.
    attr_accessor :url 
    # Title of image for use as ALT text.
    attr_accessor :title 
    # Link to use when image is clicked on.
    attr_accessor :link 
    # Width of image in pixels, as an integer.
    attr_reader :width 
    # Height of image in pixels, as an integer.
    attr_reader :height 

    # Set width in pixels.
    def width=(x)
      if x.kind_of?(String)
        @width = x.to_i
      end
    end

    # Set height in pixels.
    def height=(x)
      if x.kind_of?(String)
        @height = x.to_i
      end
    end
  end

  # Represents a text input box to be used in association with an RSS feed, for
  # example a search box or e-mail subscription input box.  
  #
  # Typically found via Syndication::Channel#textinput method. 
  class TextInput < Container
    # Label for Submit button in text input area.
    attr_accessor :title 
    # Label to explain purpose of text input area.
    attr_accessor :description 
    # Name of text object in input area, for form submission.
    attr_accessor :name 
    # URL to submit data to via HTTP POST.
    attr_accessor :link end

  # Represents metadata about an RSS feed as a whole.
  # Typically found via the Syndication::RSS::Feed#channel method.
  class Channel < Container
    # The title of the channel.
    attr_accessor :title
    # The URL of the web site this is a channel for.
    attr_accessor :link 
    # A textual description of the channel.
    attr_accessor :description 
    # Copyright statement for channel.
    attr_accessor :copyright 
    # ISO code for the language the channel is written in.
    attr_accessor :language 
    # E-mail address of person responsible for editorial content.
    attr_accessor :managingeditor 
    # E-mail address of person responsible for technical issues with feed.
    attr_accessor :webmaster 
    # Publication date of content in channel.
    attr_writer :pubdate 
    # Last time content in channel changed.
    attr_writer :lastbuilddate 
    # The graphical image to represent the channel, as a 
    # Syndication::Image object.
    attr_accessor :image 
    # One or more categories for the channel, as an Array of Strings.
    attr_accessor :category 
    alias category= store_category
    # The software that generated the channel.
    attr_accessor :generator 
    # The URL of some documentation on what the RSS format is.
    attr_accessor :docs 
    # Time to live for this copy of the channel.
    attr_accessor :ttl 
    # rssCloud interface (for Radio UserLand).
    attr_accessor :cloud 
    # PICS rating for channel.
    attr_accessor :rating 
    # The TextInput area as a Syndication::TextInput object.
    attr_accessor :textinput 
    # Hours when the feed can be skipped (because it will not have new content).
    # Returned as an Array of values in the range 0..23 (even if parsing the
    # UserLand variant of RSS 0.91).
    attr_reader :skiphours 
    # Full names (in English) of days when the feed can be skipped.
    attr_reader :skipdays 

    # Publication date of content in channel, as a DateTime object if it
    # can be parsed by DateTime; otherwise, as a String.
    def pubdate
      return parse_date(@pubdate)
    end

    # Last time content in channel changed, as a DateTime object if it
    # can be parsed by DateTime; otherwise, as a String.
    def lastbuilddate
      return parse_date(@lastbuilddate)
    end

    # Add an hour to the list of hours to skip.
    #
    # The <hour> element in fact comes inside <skipHours>, but we don't enforce
    # that; we just make the Channel recognize it and store the values.
    def hour=(hr)
      if hr.kind_of?(String)
        if !@skiphours
          @skiphours = Array.new
        end
        h = hr.to_i
        @skiphours << (h == 24 ? 0 : h)
      end
    end

    # Add a day name to the list of days to skip.
    #
    # The <day> element in fact comes inside <skipDays>, but we don't enforce
    # that; we just make the Channel recognize it and store the values.
    def day=(dayname)
      if dayname.kind_of?(String)
        if !@skipdays
          @skipdays = Array.new
        end
        @skipdays << dayname
      end
    end
  end

  # The <cloud> element is very rarely used. It was added to the RSS standards
  # to support the rssCloud protocol of Radio UserLand.
  class Cloud < Container
    # The hostname to connect to.
    attr_accessor :domain 
    # The TCP/IP port number.
    attr_reader :port 
    # The request path.
    attr_accessor :path 
    # The registration method.
    attr_accessor :registerprocedure 
    # The protocol to use.
    attr_accessor :protocol 

    # Set port number
    def port=(x)
      @port = x.to_i
    end

    def initialize(parent, tag, attrs = nil)
      @tag = tag
      @parent = parent
      if attrs
        attrs.each_pair {|key, value|
          self.store(key, value)
        }
      end
    end
  end

  # Represents a multimedia enclosure in an RSS item.
  # Typically found as Syndication::Item#enclosure
  class Enclosure < Container
    # The URL to the multimedia file.
    attr_accessor :url 
    # The MIME type of the file.
    attr_accessor :type 
    # The length of the file, in bytes.
    attr_reader :length 

    # Set length in bytes.
    def length=(x)
      @length = x.to_i
    end

    def initialize(parent, tag, attrs = nil)
      @tag = tag
      @parent = parent
      if attrs
        attrs.each_pair {|key, value|
          self.store(key, value)
        }
      end
    end
  end

  # Represents a parsed RSS feed, as returned by Syndication::RSS::Parser.
  class Feed < Container
    # The Channel metadata and contents of the feed as a 
    # Syndication::Channel object
    attr_accessor :channel 
    # The items in the feed as an Array of Syndication::Item objects.
    attr_reader :items
    # The text input area as a Syndication::TextInput object.
    attr_accessor :textinput
    # The image for the feed, as a Syndication::Image object.
    attr_accessor :image

    # Add an item to the feed.
    def item=(obj)
      if !@items
        @items = Array.new
      end
      @items.push(obj)
    end
  end

  # A parser for RSS feeds. 
  # See Syndication::Parser in common.rb for the abstract class this
  # specializes.
  class Parser < AbstractParser
    include REXML::StreamListener

    #:stopdoc:
    # A hash of tags which require the creation of new objects, and the class
    # to use for creating the object.
    CLASS_FOR_TAG = {
      'item' => Item,
      'entry' => Item,
      'image' => Image,
      'channel' => Channel,
      'cloud' => Cloud,
      'textinput' => TextInput,
      'textInput' => TextInput,
      'enclosure' => Enclosure
    }
    #:startdoc:

    # Reset the parser ready to parse a new feed.
    def reset
      # Set up an empty RSS::Feed object and make it the current object
      @parsetree = Feed.new(nil)
      # Set up the class-for-tag hash
      @class_for_tag = CLASS_FOR_TAG
      # Everything else is common to both kinds of parser
      super
    end

    # The most recently parsed feed as a Syndication::RSS::Feed object.
    def feed
      return @parsetree
    end
  end
end
end
