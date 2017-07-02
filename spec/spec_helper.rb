$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'simplecov'
SimpleCov.start

require "todoist"
require 'yaml'
require 'securerandom'

def load_client
  begin
    token = File.open("spec/token", "r").read
  rescue
    puts "Please create a file called token in the spec folder and have the first line be your Todoist token for testing purposes"
    exit  
  end
  Todoist::Client.new(token)
  
end

module Todoist
  module Util

    
    
	  class Uuid
	        
      @@type = ""
      @@uuids = {"command_uuid" => [], "temporary_resource_id" => []}
      
	    def self.command_uuid
	      return pop_uuid("command_uuid")
	    end

	  	def self.temporary_resource_id
        return pop_uuid("temporary_resource_id")
    	end	
    	
    	def self.pop_uuid(resource)
        path = "fixtures/uuid/#{@@type}_#{resource}.yml"
        # File does not exist
        if !File.exists?(path)
          100.times do
            @@uuids[resource] << SecureRandom.uuid
          end  
          File.write(path, @@uuids[resource].to_yaml) 
        elsif File.exists?(path) && @@uuids[resource].empty?
          @@uuids[resource] = YAML.load_file(path)
        end	      
        
	      return @@uuids[resource].pop
    	end
    	
    	def self.type= (type)
        reset_uuids
    	  @@type = type
    	end
    	
    	def self.type
    	  @@type
    	end
    	
    	def self.reset_uuids
    	  @@uuids = {"command_uuid" => [], "temporary_resource_id" => []}
    	end
    end
  end
end

