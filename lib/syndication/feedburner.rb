
module Syndication

  module Feedburner
    module Item
      # The original URL, before feedburner rewrote it for tracking purposes
      attr_accessor :feedburner_origlink
    end

  end

  module RSS
    class Item
      include Feedburner::Item
    end
  end

end
