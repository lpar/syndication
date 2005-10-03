# The file common.rb contains code common to both Atom and RSS parsing.
#
# Copyright © mathew <meta@pobox.com> 2005.
# Licensed under the same terms as Ruby.

require 'uri'
require 'rexml/parsers/streamparser'
require 'rexml/streamlistener'
require 'rexml/document'
require 'date'

# To parse Atom feeds, use Syndication::Atom::Parser.
# To parse RSS feeds, use Syndication::RSS::Parser.
module Syndication

  # A Container is an object in the parse tree that stores data, and possibly
  # other objects. Its naming and behavior is an internal detail, not part
  # of the API, and hence subject to change.
  #
  # In other words, to use the library you don't have to know about anything
  # below.
  class Container

    # Convert a tag (possibly with namespace) to a method name.
    def tag2method(tag)
      return tag.downcase.sub(/:/, '_') + '='
    end

    # Create a container.
    # parent is the new container's parent object in the final parse tree.
    # tag is the XML tag which caused creation of the container.
    # attrs is a hash of {attr => value} of the XML attributes in the tag.
    def initialize(parent, tag = nil, attrs = nil)
      @parent = parent
      @tag = tag
      # and ignore attrs by default
    end

    # Handle a start tag and attributes.
    # Checks to see if self has a field with the appropriate name.
    # If so, we send it the attributes (if any), and record that the
    # current method is the method to access that field.
    def tag_start(tag, attrs = nil)
      method = tag2method(tag)
      if self.respond_to?(method)
        if attrs
          self.send(method, attrs)
        end
        @current_method = method
      end
    end

    # Handle an end tag, and return what the new current object should be.
    #
    # If the tag matches the one we were created with, this container is
    # complete and the new current object is its parent. 
    #
    # If there's no parent (i.e. this is the top level container in the 
    # parse tree), the new current object must be unchanged.
    #
    # Otherwise, pass the end tag up to the parent to see if it can do
    # anything with it.
    def tag_end(endtag, current)
      if @tag == endtag
        return @parent
      end
      if @parent == nil
        return current
      end
      return @parent.tag_end(endtag, current)
    end

    # Store an object in the parse tree, either in self, or in one of self's
    # ancestors.
    def store(tag, obj)
      method = tag2method(tag)
      if self.respond_to?(method)
        self.send(method, obj)
      else
        @parent.store(tag, obj) if @parent
      end
    end

    # Parse a date field on demand. DateTime.parse is sloooow, so don't call
    # it unless you really have to.
    def parse_date(field)
      if !field
        return nil
      end
      if field.kind_of?(String)
        dt = DateTime.parse(field)
        if dt.kind_of?(DateTime)
          field = dt
        end
      end
      return field
    end

    # Strip the parent field from a container, used to make a container
    # more amenable to pretty-printing.
    def strip
      @parent = nil
      return self
    end
  end

  # Shared parts of parser code for Atom and RSS. This is an abstract class;
  # Atom::Parser and RSS::Parser are the concrete classes which actually parse
  # syndication feeds.
  #
  # You don't need to know about anything below in order to use the library.
  #
  # The basic parsing strategy is:
  #
  # - The parser keeps a current_object pointer which represents the object
  # in the parse tree that corresponds to where we are in the XML tree. To
  # use a metaphor, it's the object where parse tree growth is occurring.
  #
  # - REXML dispatches events to the parser representing start and end tags and
  # text. The parser sends the events to the current_object, which replies with
  # what the new current_object should be after the event has been dealt with.
  #
  # - The job of creating child objects when appropriate is handled by the
  # objects of the parse tree.
  #
  # - Reflection is used to store data in the parse tree. Accessor names are
  # derived from tags in a standard way once namespaces have been standardized.
  class AbstractParser 
    include REXML::StreamListener

    # A Hash of namespace URLs the module knows about, returning the standard
    # prefix to remap to.
    KNOWN_NAMESPACES = {
      'http://purl.org/dc/elements/1.1/' => 'dc',
      'http://purl.org/dc/terms/' => 'dcterms',
      'http://www.w3.org/1999/02/22-rdf-syntax-ns#' => 'rdf',
      'http://purl.org/rss/1.0/modules/content/' => 'content',
      'http://www.itunes.com/DTDs/Podcast-1.0.dtd' => 'itunes',
      'http://www.w3.org/1999/xhtml' => 'xhtml'
    }
    
    # Create a new AbstractParser. The optional argument consists of text to
    # parse.
    def initialize(text = nil)
      reset
      # Initialize mapping from tags to classes, which only needs to be done
      # once and not reset. Concrete classes which do actual parsing will
      # fill the hash.
      @tag_to_class = Hash.new
      parse(text) if text
    end

    # Catch any stuff that drops right through the parse tree, and simply 
    # ignore it.
    def store(tag, obj)
    end

    # Catch and ignore closing tags that don't match anything open.
    def end_tag(tag, current)
      return current
    end

    # Reset the parser ready to parse a new feed.
    def reset
      @current_object = @parsetree
      @tagstack = Array.new
      @textstack = Array.new
      @xhtml = ''
      @xhtmlmode = false
      @namespacemap = Hash.new
      # @parsetree is set up by the concrete classes
    end

    # Parse the text provided. Returns a Syndication::Atom::Feed or
    # Syndication::RSS::Feed object, according to which concrete Parser
    # class is being used.
    def parse(text)
      REXML::Document.parse_stream(text, self)
      return @parsetree
    end

    # Handle namespace translation for a raw tag.
    def handle_namespace(tag, attrs = nil)
      if attrs and tag.match(/^(rss|\w+:rdf|\w+:div)$/i)
        for key in attrs.keys
          if key.match(/xmlns:(\w+)/i)
            define_namespace($1, attrs[key])
          end
        end
      end
      if tag.match(/(\w+):(\w+)/)
        if @namespacemap[$1]
          tag = "#{@namespacemap[$1]}:#{$2}"
        end
      end
      return tag
    end

    # Process a namespace definition for the given prefix and namespace 
    # definition URL.
    #
    # If we recongnize the URL, we set up a mapping from their prefix to
    # our canonical choice of prefix.
    def define_namespace(prefix, url)
      myprefix = KNOWN_NAMESPACES[url]
      if myprefix
        @namespacemap[prefix] = myprefix
      end
    end

    # Called when REXML finds the start of an XML element.
    def tag_start(tag, attrs) #:nodoc:
      tag = handle_namespace(tag, attrs)
      cl = @class_for_tag[tag.downcase]
      if cl
        # If the tag requires the creation of an object, we create it as a
        # child of the current object, then ask the current object to store
        # it. It becomes the new current object.
        newobj = cl.new(@current_object, tag, attrs)
        @current_object.store(tag, newobj)
        @current_object = newobj
      else
        # Otherwise, we ask the current object to do something with the tag.
        if @current_object
          @current_object.tag_start(tag, attrs)
        end
      end
      # We also push to the stacks we use for text buffering.
      @tagstack.push(tag)
      @textstack.push('')
    end

    # Called when REXML finds the end of an XML element.
    def tag_end(endtag) 
      endtag = handle_namespace(endtag, nil)
      # There are two tasks to perform: 1. store the data from the buffers, 
      # and 2. work out if we need to close out any objects in the parse 
      # tree and move the current object pointer
      begin
        # Store the top text buffer that's on the stacks by passing it to the
        # current object along with its tag. Repeat until we find a stacked
        # tag which matches the endtag, or run out of buffers.
        tag = @tagstack.pop
        text = @textstack.pop
        if text
          text.strip!
          if text.length > 0 and @current_object
            @current_object.store(tag, text)
          end
        end
      end until tag == endtag or @tagstack.length == 0
      # Pass the tag end event to the current object to find out what the
      # new current object should be.
      if @current_object
        @current_object = @current_object.tag_end(endtag, @current_object)
      end
    end

    # Called when REXML finds a text fragment.
    # Buffers the text on the buffer stacks ready for the end tag.
    def text(s)
      if @textstack.last
        @textstack.last << s
      end
    end
  end
end
