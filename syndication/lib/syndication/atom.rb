# Provides classes for parsing Atom web syndication feeds.
# See Syndication class for documentation.
#
# Copyright © mathew <meta@pobox.com> 2005-2006.
# Licensed under the same terms as Ruby.

require 'uri'
require 'rexml/parsers/streamparser'
require 'rexml/streamlistener'
require 'rexml/document'
require 'date'
require 'syndication/common'

module Syndication

  # The Atom syndication format is defined at 
  # <URL:http://www.ietf.org/internet-drafts/draft-ietf-atompub-format-11.txt>.
  # It is finalized, and should become an RFC soon.
  #
  # For an introduction, see "An overview of the Atom 1.0 Syndication Format"
  # at <URL:http://www-128.ibm.com/developerworks/xml/library/x-atom10.html>
  #
  # For a comparison of Atom and RSS, see
  # <URL:http://www.tbray.org/atom/RSS-and-Atom>
  #
  # To parse Atom feeds, use Syndication::Atom::Parser.
  #
  # The earlier Atom 0.3 format is partially supported; the 'mode' attribute
  # is ignored and assumed to be 'xml' (as for Atom 1.0).
  #
  # Base64 encoded data in Atom 1.0 feeds is not supported (yet).
  module Atom

  # A value in an Atom feed which might be plain ASCII text, HTML, XHTML,
  # or some random MIME type.

  # TODO: Implement base64 support
  # See http://ietfreport.isoc.org/all-ids/draft-ietf-atompub-format-11.txt
  # section 4.1.3.3.

  #:stopdoc:
  # This object has to be handled specially; the parser feeds in all the
  # REXML events, so the object can reconstruct embedded XML/XHTML.
  # (Normally, the parser handles text buffering for a Container and
  # calls store() when the container's element is closed.)
  #:startdoc:
  class Data < Container
    # The decoded data, if the type is not text or XML
    attr_reader :data

    # Table of entities ripped from the XHTML spec.
    ENTITIES = {
      'Aacute' => 193, 'aacute' => 225, 'Acirc'  => 194,
      'acirc'  => 226, 'acute'  => 180, 'AElig'  => 198,
      'aelig'  => 230, 'Agrave' => 192, 'agrave' => 224,
      'amp'    => 38,  'Aring'  => 197, 'aring'  => 229,
      'Atilde' => 195, 'atilde' => 227, 'Auml'   => 196,
      'auml'   => 228, 'brvbar' => 166, 'Ccedil' => 199,
      'ccedil' => 231, 'cedil'  => 184, 'cent'   => 162,
      'copy'   => 169, 'curren' => 164, 'deg'    => 176,
      'divide' => 247, 'Eacute' => 201, 'eacute' => 233,
      'Ecirc'  => 202, 'ecirc'  => 234, 'Egrave' => 200,
      'egrave' => 232, 'ETH'    => 208, 'eth'    => 240,
      'Euml'   => 203, 'euml'   => 235, 'frac12' => 189,
      'frac14' => 188, 'frac34' => 190, 'gt'     => 62,
      'Iacute' => 205, 'iacute' => 237, 'Icirc'  => 206,
      'icirc'  => 238, 'iexcl'  => 161, 'Igrave' => 204,
      'igrave' => 236, 'iquest' => 191, 'Iuml'   => 207,
      'iuml'   => 239, 'laquo'  => 171, 'lt'     => 60,
      'macr'   => 175, 'micro'  => 181, 'middot' => 183,
      'nbsp'   => 160, 'not'    => 172, 'Ntilde' => 209,
      'ntilde' => 241, 'Oacute' => 211, 'oacute' => 243,
      'Ocirc'  => 212, 'ocirc'  => 244, 'Ograve' => 210,
      'ograve' => 242, 'ordf'   => 170, 'ordm'   => 186,
      'Oslash' => 216, 'oslash' => 248, 'Otilde' => 213,
      'otilde' => 245, 'Ouml'   => 214, 'ouml'   => 246,
      'para'   => 182, 'plusmn' => 177, 'pound'  => 163,
      'quot'   => 34,  'raquo'  => 187, 'reg'    => 174,
      'sect'   => 167, 'shy'    => 173, 'sup1'   => 185,
      'sup2'   => 178, 'sup3'   => 179, 'szlig'  => 223,
      'THORN'  => 222, 'thorn'  => 254, 'times'  => 215,
      'Uacute' => 218, 'uacute' => 250, 'Ucirc'  => 219,
      'ucirc'  => 251, 'Ugrave' => 217, 'ugrave' => 249,
      'uml'    => 168, 'Uuml'   => 220, 'uuml'   => 252,
      'Yacute' => 221, 'yacute' => 253, 'yen'    => 165,
      'yuml'   => 255
    }

    def initialize(parent, tag, attrs = nil)
      @tag = tag
      @parent = parent
      @type = 'text' # the default, as per the standard
      if attrs['type']
        @type = attrs['type']
      end
      @div_trimmed = false
      case @type
      when 'xhtml'
        @xhtml = ''
      when 'html'
        @html = ''
      when 'text'
        @text = ''
      end
    end

    # Convert a text representation to HTML.
    def text2html(text)
      html = text.gsub('&','&amp;')
      html.gsub!('<','&lt;')
      html.gsub!('>','&gt;')
      return html
    end

    # Convert an HTML representation to text.
    # This is done by throwing away all tags and converting all entities.
    # Not ideal, but I can't think of a better simple approach.
    def html2text(html)
      text = html.gsub(/<[^>]*>/, '')
      text = text.gsub(/&(\w)+;/) {|x|
        ENTITIES[x] ? ENTITIES[x] : ''
      }
      return text
    end

    # Return value of Data as HTML.
    def html
      return @html if @html
      return @xhtml if @xhtml
      return text2html(@text) if @text
      return nil
    end

    # Return value of Data as ASCII text.
    # If the field started off as (X)HTML, this is done by ruthlessly
    # discarding markup and entities, so it is highly recommended that you
    # use the XHTML or HTML and convert to text in a more intelligent way.
    def txt
      return @text if @text
      return html2text(@xhtml) if @xhtml
      return html2text(@html) if @html
      return nil
    end

    # Return value of Data as XHTML.
    def xhtml
      return @xhtml if @xhtml
      return @html if @html
      return text2html(@text) if @text
      return nil
    end

    # Catch tag start events if we're collecting embedded XHTML.
    def tag_start(tag, attrs = nil)
      if @type == 'xhtml'
        t = tag.sub(/^xhtml:/,'')
        @xhtml += "<#{t}>"
      else
        super
      end
    end

    # Catch tag end events if we're collecting embedded XHTML.
    def tag_end(endtag, current)
      if @tag == endtag
        if @type == 'xhtml' and !defined? @div_stripped
          @xhtml.sub!(/^\s*<div>\s*/m,'')
          @xhtml.sub!(/\s*<\/div>\s*$/m,'')
          @div_stripped = true
        end
        return @parent
      end
      if @type == 'xhtml'
        t = endtag.sub(/^xhtml:/,'')
        @xhtml += "</#{t}>"
        return self
      else
        super
      end
    end

    # Store/buffer text in the appropriate internal field.
    def text(s)
      case @type
      when 'xhtml'
        @xhtml += s
      when 'html'
        @html += s
      when 'text'
        @text += s
      end
    end
  end

  # A Link represents a hypertext link to another object from an Atom feed.
  # Examples include the link with rel=self to the canonical URL of the feed.
  class Link < Container
    attr_accessor :href # The URI of the link.
    attr_accessor :rel # The type of relationship the link expresses.
    attr_accessor :type # The type of object at the other end of the link.
    attr_accessor :title # The title for the link.
    attr_accessor :length # The length of the linked-to object in bytes.

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

  # A person, corporation or similar entity within an Atom feed.
  class Person < Container
    attr_accessor :name # Human-readable name of person.
    attr_accessor :uri # URI associated with the person.
    attr_accessor :email # RFC2822 e-mail address of person.

    # For Atom 0.3 compatibility
    def url=(x)
      @uri = x
    end
  end

  # A category (keyword) in an Atom feed.
  # For convenience, Category#to_s is the same as Category#label.
  class Category < Container
    # The category itself, possibly encoded.
    attr_accessor :term 
    # A human-readable version of Category#term.
    attr_accessor :label 
    # URI to the schema definition.
    attr_accessor :scheme 

    #:stopdoc:
    # parent = parent object
    # tag = XML tag which caused creation of this object
    # attrs = XML attributes as a hash
    def initialize(parent, tag, attrs = nil)
      @tag = tag
      @parent = parent
      if attrs
        attrs.each_pair {|key, value|
          self.store(key, value)
        }
      end
    end

    alias to_s label
    #:startdoc:
  end

  # Represents a parsed Atom feed, as returned by Syndication::Atom::Parser.
  class Feed < Container
    # Title of feed as a Syndication::Data object.
    attr_accessor :title 
    # Subtitle of feed as a Syndication::Data object.
    attr_accessor :subtitle 
    # Last update time, accepts an ISO8601 date/time as per the Atom spec.
    attr_writer :updated 
    # Software which generated feed as a String.
    attr_accessor :generator 
    # URI of icon to represent channel as a String.
    attr_accessor :icon 
    # Globally unique ID of feed as a String.
    attr_accessor :id 
    # URI of logo for channel as a String.
    attr_accessor :logo 
    # Copyright or other rights information as a String.
    attr_accessor :rights 
    # Author of feed as a Syndication::Person object.
    attr_accessor :author 
    # Array of Syndication::Entry objects representing the entries in the feed.
    attr_reader :entries 
    # Array of Syndication::Category objects representing taxonomic 
    # categories for the feed.
    attr_reader :categories 
    # Array of Syndication::Person objects representing contributors.
    attr_reader :contributors 
    # Array of Syndication::Link objects representing various types of link.
    attr_reader :links 
    # Atom 0.3 info element (obsolete)
    attr_accessor :info

    # For Atom 0.3 compatibility
    def tagline=(x)
      @subtitle = x
    end

    # For Atom 0.3 compatibility
    def copyright=(x)
      @rights = x
    end

    # For Atom 0.3 compatibility
    def modified=(x)
      @updated = x
    end

    # Add a Syndication::Category value to the feed
    def category=(obj)
      if !defined? @categories
        @categories = Array.new
      end
      @categories.push(obj)
    end

    # Add a Syndication::Entry to the feed
    def entry=(obj)
      if !defined? @entries
        @entries = Array.new
      end
      @entries.push(obj)
    end

    # Add a Syndication::Person contributor to the feed
    def contributor=(obj)
      if !defined? @contributors
        @contributors = Array.new
      end
      @contributors.push(obj)
    end

    # Add a Syndication::Link to the feed
    def link=(obj)
      if !defined? @links
        @links = Array.new
      end
      @links.push(obj)
    end

    # Last update date/time as a DateTime object if it can be parsed,
    # a String otherwise.
    def updated
      parse_date(@updated)
    end
  end

  # An entry within an Atom feed.
  class Entry < Container
    # Title of entry.
    attr_accessor :title 
    # Summary of content.
    attr_accessor :summary 
    # Source feed metadata as Feed object.
    attr_accessor :source 
    # Last update date/time as DateTime object.
    attr_writer :updated 
    # Publication date/time as DateTime object.
    attr_writer :published 
    # Author of entry as a Person object.
    attr_accessor :author 
    # Copyright or other rights information.
    attr_accessor :rights 
    # Content of entry.
    attr_accessor :content 
    # Globally unique ID of Entry.
    attr_accessor :id 
    # Array of taxonomic categories for feed.
    attr_reader :categories 
    # Array of Link objects.
    attr_reader :links 
    # Array of Person objects representing contributors.
    attr_reader :contributors 
    # Atom 0.3 creation date/time (obsolete)
    attr_writer :created

    # For Atom 0.3 compatibility
    def modified=(x)
      @updated = x
    end

    # For Atom 0.3 compatibility
    def issued=(x)
      @published = x
    end

    # For Atom 0.3 compatibility
    def copyright=(x)
      @rights = x
    end

    # Add a Category object to the entry
    def category=(obj)
      if !defined? @categories
        @categories = Array.new
      end
      @categories.push(obj)
    end

    # Add a Person to the entry to represent a contributor
    def contributor=(obj)
      if !defined? @contributors
        @contributors = Array.new
      end
      @contributors.push(obj)
    end

    # Add a Link to the entry
    def link=(obj)
      if !defined? @links
        @links = Array.new
      end
      @links.push(obj)
    end

    # The last update DateTime
    def updated
      parse_date(@updated)
    end

    # The DateTime of publication
    def published
      parse_date(@published)
    end

    # The DateTime of creation (Atom 0.3, obsolete)
    def created
      parse_date(@created)
    end
  end

  # A parser for Atom feeds.
  # See Syndication::Parser in common.rb for the abstract class this
  # specializes.
  class Parser < AbstractParser
    include REXML::StreamListener

    #:stopdoc:
    # A hash of tags which require the creation of new objects, and the class
    # to use for creating the object.
    CLASS_FOR_TAG = {
      'entry' => Entry,
      'author' => Person,
      'contributor' => Person,
      'title' => Data,
      'subtitle' => Data,
      'summary' => Data,
      'link' => Link,
      'source' => Feed,
      'category' => Category
    }

    # Called when REXML finds a text fragment.
    # For Atom parsing, we need to handle Data objects specially:
    # They need all events passed through verbatim, because 
    # they might contain XHTML which will be sent through
    # as REXML events and will need to be reconstructed.
    def text(s)
      if @current_object.kind_of?(Data)
        @current_object.text(s)
        return
      end
      if @textstack.last
        @textstack.last << s
      end
    end
    #:startdoc:

    # Reset the parser ready to parse a new feed.
    def reset
      # Set up an empty Feed object and make it the current object
      @parsetree = Feed.new(nil)
      # Set up the class-for-tag hash
      @class_for_tag = CLASS_FOR_TAG
      # Everything else is common to both kinds of parser
      super
    end

    # The most recently parsed feed as a Syndication::Feed object.
    def feed
      return @parsetree
    end

  end
  end
end
