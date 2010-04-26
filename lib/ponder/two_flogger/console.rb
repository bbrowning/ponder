module Ponder
  module TwoFlogger
    class Console
      attr_accessor :current_log_level, :time_format

      def initialize(levels = nil, time_format = '%d.%m.%Y %H:%M:%S')
        @levels = levels || {:debug => 0, :info => 1, :warn => 2, :error => 3, :fatal => 4, :unknown => 5}
        @time_format = time_format
        @log_queue = Queue.new
        @log_mutex = Mutex.new
        @running = false
        define_level_shorthand_methods
      end
      
      def start_logger
        @running = true
        @log_thread = Thread.new do
          while @running do
            write(@log_queue.pop) 
          end
        end
      end

      def stop_logger
        @running = false
      end

      def levels=(levels = {})
        
      end

      private

      def define_level_shorthand_methods
        @levels.each_pair do |level_name, severity|
          define_method(level_name) { |*messages| queue severity, *messages }
        end
      end

      def queue(severity, *messages)
        raise(ArgumentError, 'Need a message') if messages.empty?
        raise(ArgumentError, 'Need messages that respond to #to_s') if messages.any? { |message| !message.respond_to?(:to_s) }
        @log_mutex.synchronize do
          @log_queue << messages if severity >= @current_log_level
        end
      end

      def write(messages)
        begin
          messages.each do |message|
            puts "#{@levels.index(severity)} #{Time.now.strftime(@time_format)} #{message}"
          end
        rescue => e
          puts e.message, *e.backtrace
        end
      end
      
    end
  end
end