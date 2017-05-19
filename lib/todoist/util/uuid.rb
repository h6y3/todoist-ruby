require 'securerandom'

module Todoist
  module Util

	  class Uuid
	    
	    def self.command_uuid 
	      return SecureRandom.uuid 
	    end

	  	def self.temporary_resource_id
	      return SecureRandom.uuid 
    	end	
    end
  end
end
