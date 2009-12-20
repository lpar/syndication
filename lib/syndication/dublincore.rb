# Copyright © mathew <meta@pobox.com> 2005.
# Licensed under the same terms as Ruby.
# 
# $Header$

module Syndication

  # Mixin for Dublin Core metadata in RSS feeds.
  #
  # If you require 'syndication/dublincore' these methods are added to the
  # Syndication::Channel, Syndication::Item, Syndication::Image and 
  # Syndication::TextInput classes.
  #
  # The access method names are the Dublin Core element names, prefixed with
  # dc_.
  #
  module DublinCore
    # A name by which the item is formally known.
    attr_accessor :dc_title 

    # The entity primarily responsible for making the content of the item.
    attr_accessor :dc_creator 

    # The topic of the content of the item, typically as keywords 
    # or key phrases.
    attr_accessor :dc_subject

    # A description of the content of the item.
    attr_accessor :dc_description

    # Entity responsible for making the item available.
    attr_accessor :dc_publisher 

    # Entity responsible for contributing this item.
    attr_accessor :dc_contributor

    # Date of creation or availability of item.
    # Returned as a DateTime if it will parse; otherwise, returned as a
    # string. (Dublin Core does not require any particular date and time
    # format, so guaranteeing parsing is not possible.)
    def dc_date
      if @dc_date and !@dc_date.kind_of?(DateTime)
        @dc_date = DateTime.parse(@dc_date)
      end
      return @dc_date
    end

    # Date of creation or availability of item.
    attr_writer :dc_date

    # Nature or genre of item, usually from a controlled vocabulary.
    attr_accessor :dc_type

    # Physical or digital format of item.
    attr_accessor :dc_format

    # An unambigious identifier which identifies the item.
    attr_accessor :dc_identifier

    # A reference to a resource from which the item is derived.
    attr_accessor :dc_source

    # The language the item is in, coded as per RFC 1766.
    attr_accessor :dc_language

    # A reference to a related resource.
    attr_accessor :dc_relation

    # The extent or scope of coverage of the item, e.g. a geographical area.
    attr_accessor :dc_coverage

    # Information about rights held over the item, e.g. copyright or patents.
    attr_accessor :dc_rights
  end

  #:enddoc:
  module RSS
    # Now we mix in the DublinCore elements to all the Syndication classes that
    # can contain them. There's probably some clever way to do this via 
    # reflection, but there _is_ such a thing as being too clever.
    class Item
      include DublinCore
    end

    class Channel
      include DublinCore
    end

    class Image
      include DublinCore
    end

    class TextInput
      include DublinCore
    end
  end

end
