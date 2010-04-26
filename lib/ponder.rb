require 'pathname'
require "rubygems"
require "bundler"
Bundler.setup

$LOAD_PATH.unshift Pathname(__FILE__).dirname.expand_path

Thread.abort_on_exception = true

module Ponder
  def self.root
    Pathname($0).dirname.expand_path
  end

  require 'ponder/thaum'
  require 'ponder/formatting'
end

class Object
  module InstanceExecHelper; end
  include InstanceExecHelper
  def instance_exec(*args, &block) # !> method redefined; discarding old instance_exec
    mname = "__instance_exec_#{Thread.current.object_id.abs}_#{object_id.abs}"
    InstanceExecHelper.module_eval{ define_method(mname, &block) }
    begin
      ret = send(mname, *args)
    ensure
      InstanceExecHelper.module_eval{ undef_method(mname) } rescue nil
    end
    ret
  end
end