require 'concurrent'
require "todoist/util/api_helper"

module Todoist

  module Util
    class CommandSynchronizer
      
      @@command_cache = Concurrent::Array.new([])
      @@command_mutex = Mutex.new
      @@temp_id_callback_cache = Concurrent::Array.new([])
      
      def self.start
        @@sync_thread = Thread.new do
          while(true) do
            process()
            sleep(3)
          end          
        end unless @@sync_thread
      end
      
      def self.stop
        Thread.kill(@@sync_thread) if @@sync_thread
        @@sync_thread = nil
      end
        
      def self.queue(command, callback = nil) 
        @@command_mutex.synchronize do
          @@command_cache.push(command)
          @@temp_id_callback_cache.push(callback) if callback
        end
      end
      
      def self.sync
        @@command_mutex.synchronize do    
          response = ApiHelper.getSyncResponse({commands: @@command_cache.to_json})
          @@command_cache.clear
          # Process callbacks here
          temp_id_mappings = response["temp_id_mapping"]
          @@temp_id_callback_cache.each do |callback| 
              callback.(temp_id_mappings)
          end
          @@temp_id_callback_cache.clear
        end
      end

      
      protected
        
    end

  end

end