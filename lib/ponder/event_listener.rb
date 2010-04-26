module Ponder
  class EventListener
    LISTENED_TYPES = [:connect, :channel, :query, :join, :part, :quit, :nickchange, :kick] # + 3-digit numbers

    attr_reader :event_type

    def initialize(target = nil, event_type = :channel, match = //, proc = Proc.new {})
      self.target = target
      self.event_type = event_type
      self.match = match
      self.proc = proc
    end

    def call(event_type, event_data)
      if (event_type == :channel) || (event_type == :query)
        @target.instance_exec(event_data, &@proc) if event_data[:message] =~ @match
      else
        @target.instance_exec(event_data, &@proc)
      end
    end

    protected

    def target=(target)
      unless target.nil?
        @target = target
      else
        raise ArgumentError, "target must not be nil"
      end
    end

    def event_type=(type)
      if (type.is_a?(Symbol) || type.is_a?(String))
        @event_type = type.to_sym

        unless (LISTENED_TYPES.include?(@event_type) || @event_type =~ /^\d\d\d$/)
          raise TypeError, "#{type} is an unsupported event-type"
        end
      else
        raise TypeError, "#{type} must be a String, Symbol or 3-digit number"
      end
    end

    def match=(match)
      if match.is_a?(Regexp)
        @match = match
      else
        raise TypeError, "#{match} must be a Regexp"
      end
    end

    def proc=(proc)
      if proc.is_a?(Proc)
        @proc = proc
      else
        raise TypeError, "#{proc} must be a Proc"
      end
    end
  end
end
