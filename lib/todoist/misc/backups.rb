module Todoist
  module Misc
    class Backups < Todoist::Service
        include Todoist::Util  
        
        # Returns the backups for a user.
        def get()
          result = @api_helper.get_response(Config::TODOIST_BACKUPS_GET_COMMAND, {})
          ParseHelper.make_objects_as_hash(result)
        end
    end
  end
end
