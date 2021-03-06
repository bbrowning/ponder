require 'pathname'
$LOAD_PATH.unshift Pathname.new(__FILE__).dirname.expand_path.join('..', 'lib')

require 'ponder'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

# This Thaum answers the channel message "blog?" with the title of the newest github blog entry.
@ponder = Ponder::Thaum.new

@ponder.configure do |c|
  c.server    = 'chat.freenode.org'
  c.port      = 6667
  c.nick      = 'Ponder'
  c.verbose   = true
  c.logging   = false
end

@ponder.on :connect do
  @ponder.join '#ponder'
end

@ponder.on :channel, /^blog\?$/ do |event_data|
  doc = Nokogiri::HTML(open('http://github.com/blog'))
  title = doc.xpath('//html/body/div/div[2]/div/div/ul/li/h2/a')[0].text
  
  @ponder.message event_data[:channel], "Newest Github Blog Post: #{title}"
end

@ponder.connect
