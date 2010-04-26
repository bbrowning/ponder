require 'pathname'
require Pathname(__FILE__) + "../../lib/ponder.rb"

@ponder = Ponder::Thaum.new

@ponder.delegate!

on :connect do
  join '#test'
end

on :channel, /^!quit$/ do
  quit
end

on :channel, /^online\?/ do |env|
  message env[:channel], "is not online!"
end

connect