
require 'date'

module Syndication

  # Mixin for RSS 1.0 syndication data (draft standard for RSS 1.0).
  #
  # If you require 'syndication/syndication' these methods are added to the
  # Syndication::Channel class.
  #
  # Access methods are named after the XML elements, prefixed with sy_.
  #
  module Syndication
    # The period over which the channel is updated. Allowed values are
    # 'hourly', 'daily', 'weekly', 'monthly', 'yearly'. If omitted, 'daily'
    # is assumed.
    attr_accessor :sy_updateperiod

    # Frequency of updates, in relation to sy_updateperiod. Indicates how many
    # times in each sy_updateperiod the channel is updated. For example,
    # sy_updateperiod = 'daily' and sy_updatefrequency = 4 means four times
    # per day.
    attr_accessor :sy_updatefrequency

    # Base date used to calculate publishing times. When combined with 
    # sy_updateperiod and sy_updatefrequency, the publishing schedule can 
    # be derived. Returned as a DateTime if possible, otherwise as a String.
    attr_reader :sy_updatebase

    def sy_updatebase=(x)
      d = DateTime.parse(x)
      if d
        @sy_updatebase = d
      else
        @sy_updatebase = x
      end
    end
  end

  #:enddoc:
  class Channel
    include Syndication
  end

end
