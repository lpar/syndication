# Copyright © mathew <meta@pobox.com> 2005-2006.
# Licensed under the same terms as Ruby.

require 'cgi'

module Syndication

  # TagSoup is a tiny completely non-validating XML parser which implements the
  # tag_start, tag_end and text methods of the REXML StreamListener interface.
  #
  # It's designed for permissive parsing of RSS and Atom feeds; using it for
  # anything more complex (like HTML with CSS and JavaScript) is not advised.
  class TagSoup

    # Parse data String and send events to listener
    def TagSoup.parse_stream(data, listener)
      data.scan(/(<\/[^>]*>|<[^>]*>|[^<>]*)/m) do |match|
        thing = match.first.strip
        if thing[0,1] == '<'
          # It's a tag_start or tag_end
          (tag,rest) = thing.match(/<\/?([^>\s]+)([^>]*)/)[1,2]
          if thing[1,1] == '/'
            listener.tag_end(tag)
          else
            # Parse the attr=val pairs
            pairs = Hash.new
            rest.scan(/([\w:]+)=("([^"]*)"|'([^']*)')/) {|a,j,v1,v2|
              if v1 == nil
                v = v2
              else
                v = v1
              end
              if a
                pairs[a] = v
              end
            }
            listener.tag_start(tag, pairs)
            # Tags with end tag build in, XML style
            if thing[-2,1] == '/'
              listener.tag_end(tag)
            end
          end
        else
          # It's text
          listener.text(CGI.unescapeHTML(thing))
        end
      end
    end

  end
end
