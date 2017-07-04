module Todoist
  class Service    
    include Todoist::Util 

    def initialize(client)
      @client = client
    end
    
  end
end
