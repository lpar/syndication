module Syndication

  # Mixin for iTunes podcast RSS elements.
  #
  # To use this, require 'syndication/podcast' to add appropriate methods
  # to the Item and Channel classes.
  #
  # See <URL:http://phobos.apple.com/static/iTunesRSS.html> for more
  # information.
  #
  # See Syndication::Podcast::Both for methods added to both Item and
  # Channel RSS objects.
  #
  # See Syndication::Podcast::Channel for methods added to Channel objects.
  #
  # See Syndication::Podcast::Item for methods added to Item objects.
  #
  module Podcast
    # iTunes fields which occur in Items only.
    module Item
      # Artist column in iTunes.
      attr_accessor :itunes_author
      # Duration of item, in seconds.
      attr_reader :itunes_duration

      # Set the duration. Apple specifies four possible formats for the
      # XML data: HH:MM:SS, H:MM:SS, MM:SS, or M:SS.
      def itunes_duration=(x)
        if x.match(/(\d?\d):(\d\d):(\d\d)/)
          @itunes_duration = $3.to_i + $2.to_i * 60 + $1.to_i * 3600
        elsif x.match(/(\d?\d):(\d\d)/)
          @itunes_duration = $2.to_i + $1.to_i * 60
        end
      end

    end

    # iTunes fields which occur in Channels only.
    module Channel
      # Owner, not shown, used for contact only.
      attr_accessor :itunes_owner
    end

    # iTunes fields which occur both in Channels and in Items.
    module Both
      # Prevent this entity from appearing in the iTunes podcast directory?
      attr_accessor :itunes_block
      # Parental advisory graphic?
      attr_accessor :itunes_explicit
      # Keywords, not shown but can be searched via iTunes.
      attr_accessor :itunes_keywords
      # Description column in iTunes.
      attr_accessor :itunes_subtitle
      # Summary, shown when i-in-circle icon is clicked in Description 
      # column of iTunes.
      attr_accessor :itunes_summary
      # Category column(s) in iTunes and music store browser, as an array
      # of strings (categories then subcategories).
      attr_reader :itunes_category

      # Add an iTunes category; they can be nested.
      def itunes_category=(x)
        if !@itunes_category
          @itunes_category = Array.new
        end
        @itunes_category.push(x)
      end

    end
  end

  #:enddoc:
  module RSS
    class Item
      include Podcast::Item
      include Podcast::Both
    end

    class Channel
      include Podcast::Channel
      include Podcast::Both
    end
  end

end
