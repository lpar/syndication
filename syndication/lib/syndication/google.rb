# Copyright © mathew <meta@pobox.com> 2006.
# Licensed under the same terms as Ruby.

module Syndication

  # Mixin for Google Data in Atom feeds.
  #
  # If you require 'syndication/google' these methods are added to the
  # Syndication::Atom::Entry and Syndication::Atom::Feed classes.
  module Google
    # Where the event is to occur
    attr_reader :gd_where

    def gd_where=(attrs)
      if attrs['valueString']
        @gd_where = attrs['valueString']
      end
    end

    def gd_when=(attrs)
      if attrs['startTime']
        @starttime = attrs['startTime']
      end
      if attrs['endTime']
        @endtime = attrs['endTime']
      end
    end

    def gd_when
      s = e = nil
      if @starttime
        s = DateTime.parse(@starttime)
      end
      if @endtime
        e = DateTime.parse(@endtime)
      end
      return [s,e]
    end
  end

  module Atom
    class Entry
      include Google
    end

    class Feed
      include Google
    end
  end

end
