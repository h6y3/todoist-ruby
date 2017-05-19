module Todoist
  module Misc
    class Backups
        include Todoist::Util  
        
        # Returns the backups for a user.
        def get()
          result = NetworkHelper.getResponse(Config::TODOIST_BACKUPS_GET_COMMAND, {})
          ParseHelper.make_objects_as_array(result)
        end
    end
  end
end
