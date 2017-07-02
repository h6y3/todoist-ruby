module Todoist
  module Misc
    class Completed < Todoist::Service
        include Todoist::Util  
        
        # Get productivity stats.  Returns a hash of statistics as documented
        # at https://developer.todoist.com/#get-productivity-stats
        def get_productivity_stats()
          @api_helper.get_response(Config::TODOIST_COMPLETED_GET_STATS_COMMAND)
        end
        
        # Retrieves all completed items as documented at 
        # https://developer.todoist.com/#get-all-completed-items.  Several parameters
        # are possible to limit scope.  See link.  Dates should be passed
        # as DateTime.  This method takes care of the formatting to send to the
        # API.  Returns projects and items back as :items and :projects keys.
        
        def get_all_completed_items(params = {})
          if params["until"]
            params["until"] = ParseHelper.format_time(params["until"])
          end
          if params["since"]
            params["since"] = ParseHelper.format_time(params["since"])
          end
          
          result = @api_helper.get_response(Config::TODOIST_COMPLETED_GET_ALL_COMMAND, params)
          items = ParseHelper.make_objects_as_array(result["items"])
          projects = ParseHelper.make_objects_as_array(result["projects"])
          return {"items" => items, "projects" => projects}
        end
        
    end
  end
end
