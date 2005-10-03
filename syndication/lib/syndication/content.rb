
module Syndication

  # Mixin for RSS 1.0 content module.
  #
  # This is the approved way to include actual HTML text in an RSS feed.
  # To use it, require 'syndication/content' to add the content_encoded
  # and content_decoded methods to the Syndication::Item class.
  #
  module Content
    # Actual web content, entity encoded or CDATA-escaped.
    attr_accessor :content_encoded

    # Decoded version of content_encoded, as HTML.
    def content_decoded
      if !@content_encoded or @content_encoded == ''
        return @content_encoded
      end
      # CDATA is the easier
      if @content_encoded.match(/<!\[CDATA\[(.*)\]\]!>/)
        return $1
      end
      # OK, must be entity-encoded
      x = @content_encoded.gsub(/&lt;/, '<')
      x.gsub!(/&gt;/, '>')
      return x.gsub(/&amp;/, '&')
    end
  end

  #:enddoc:
  module RSS
    class Item
      include Content
    end
  end

end