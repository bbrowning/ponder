require 'thread'
require 'timeout'

module Ponder
  module AsyncIRC
    def get_topic(channel)
      queue = Queue.new
      @observer_queues[queue] = [/:\S+ (331|332|403|442) \S+ #{Regexp.escape(channel)} :/i]
      raw "TOPIC #{channel}"
      
      topic = begin
        Timeout::timeout(30) do
           response = queue.pop
           raw_numeric = response.scan(/^:\S+ (\d{3})/)[0][0]
           
           case raw_numeric
           when '331'
             {:raw_numeric => 331, :message => 'No topic is set'}
           when '332'
             {:raw_numeric => 332, :message => response.scan(/^ :(.*)/)[0][0]}
           when '403'
             {:raw_numeric => 403, :message => 'No such channel'}
           when '442'
             {:raw_numeric => 442, :message => "You're not on that channel"}
           end
        end
      rescue Timeout::Error
        false
      end
      
      @observer_queues.delete queue
      return topic
    end
    
    def channel_info(channel)
      queue = Queue.new
      @observer_queues[queue] = [/:\S+ (324|329|403) \S+ #{Regexp.escape(channel)}/i]
      raw "MODE #{channel}"
      information = {}
      running = true
      
      begin
        Timeout::timeout(30) do
          while running
            response = queue.pop
            raw_numeric = response.scan(/^:\S+ (\d{3})/)[0][0]
            
             case raw_numeric
             when '324'
               information[:modes] = response.scan(/^:\S+ 324 \S+ \S+ \+(\w*)/)[0][0].split('')
               limit = response.scan(/^:\S+ 324 \S+ \S+ \+\w* (\w*)/)[0]
               information[:channel_limit] = limit[0].to_i if limit
             when '329'
               information[:created_at] = Time.at(response.scan(/^:\S+ 329 \S+ \S+ (\d+)/)[0][0].to_i)
               running = false
             when '403'
               information = false
               running = false
             end
           end
        end
      rescue Timeout::Error
        information = false
      end
      
      @observer_queues.delete queue
      return information
    end
    
    def is_online(nick)
      queue = Queue.new
      @observer_queues[queue] = [/:\S+ (311|401) \S+ #{Regexp.escape(nick)}/i]
      raw "WHOIS #{nick}"
      
      topic = begin
        Timeout::timeout(30) do
           response = queue.pop
           raw_numeric = response.scan(/^:\S+ (\d{3})/)[0][0]
           
           case raw_numeric
           when '311'
             response.scan(/^:\S+ 311 \S+ (\S+)/)[0][0]
           when '401'
             false
           end
        end
      rescue Timeout::Error
        nil
      end
      
      @observer_queues.delete queue
      return topic
    end
  end
end