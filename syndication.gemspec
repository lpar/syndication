# encoding: UTF-8

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'syndication/syndication'

spec = Gem::Specification.new do |s|
  s.name = "syndication"
  s.version = Syndication::VERSION
  s.author = "mathew"
  s.email = "meta@pobox.com"
  s.homepage = "https://launchpad.net/ruby-syndication"
  s.platform = Gem::Platform::RUBY
  s.description = <<-EOF
  Syndication is a parser for RSS and Atom feeds. It uses either REXML or
  its built-in "tag soup" parser for feed parsing. It supports extensions
  to web feeds including Dublin Core metadata, Apple iTunes podcasts, and 
  extensions from Google and Feedburner. It is written in pure Ruby, and
  designed to be easy to understand and extend. It is compatible with Ruby 
  1.8.x and 1.9.x.
  EOF
  s.rubyforge_project = 'syndication'
  s.summary = "A web syndication parser for Atom and RSS with a uniform API"
  candidates = Dir.glob("{bin,docs,lib,test,examples}/**/*")
  candidates << "rakefile"
  s.files = candidates.delete_if do |item|
    item.include?("CVS") || item.include?("html")
  end
  s.require_path = "lib"
  s.test_files = ["test/atomtest.rb", "test/rsstest.rb", "test/google.rb",
                  "test/tagsouptest.rb", "test/feedburntest.rb"]
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "IMPLEMENTATION", "CHANGES", "DEVELOPER"]
end
