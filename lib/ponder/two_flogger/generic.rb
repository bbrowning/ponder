require 'thread'
autoload :FileUtils, 'fileutils'

module Ponder
  module TwoFlogger
    class Generic
      attr_accessor :current_log_level, :time_format

      def initialize(levels = nil, time_format = '%d.%m.%Y %H:%M:%S')
        @levels = levels || {:debug => 0, :info => 1, :warn => 2, :error => 3, :fatal => 4, :unknown => 5}
        @time_format = time_format
        @log_queue = Queue.new
        @log_mutex = Mutex.new
        define_level_shortcut_methods
      end

      private

      def define_level_shorthand_methods
        @levels.each_pair do |level_name, severity|
          define_method(level_name) { |*messages| write severity, *messages }
        end
      end

      def write(severity, *messages)
        raise(ArgumentError, 'Need a message') if messages.empty?
        raise(ArgumentError, 'Need messages that respond to #to_s') if messages.any? { |message| !message.respond_to?(:to_s) }

        begin
          if severity >= @current_log_level
            @log_queue << messages
            @log_mutex.synchronize do
              messages.each do |message|
                @file.puts "#{@level.index(severity)} #{Time.now.strftime(@time_format)} #{message}"
              end
            end
          end
        rescue => e
          puts e.message, *e.backtrace
        end
      end

    end
  end
end