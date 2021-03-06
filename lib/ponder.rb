require 'pathname'
require 'rubygems'

$LOAD_PATH.unshift Pathname.new(__FILE__).dirname.expand_path

module Ponder
  def self.root
    Pathname.new($0).dirname.expand_path
  end
  
  require 'ponder/version'
  require 'ponder/thaum'
  require 'ponder/formatting'
  require 'ponder/logger/blind_io'
  
  if RUBY_VERSION < '1.9'
    require 'ponder/logger/twoflogger18'
  else
    require 'ponder/logger/twoflogger'
  end
end

