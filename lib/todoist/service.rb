module Todoist
  class Service    
    include Todoist::Util 

    def initialize(client)
      @client = client
      @api_helper = ApiHelper.new(client)
    end

    def sync
      @api_helper.sync  
    end
    
  end
end
