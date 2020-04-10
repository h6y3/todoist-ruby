module Todoist
  module Misc
    class Activity < Todoist::Service
        include Todoist::Util

        # Returns the activity logs for a user.  

        def get(params={})
          if params["until"]
            params["until"] = ParseHelper.format_time(params["until"])
          end

          if params["since"]
            params["since"] = ParseHelper.format_time(params["since"])
          end

          if params["object"]
            params["object_id"] = params["object"].id
            params.delete("object")
          end

          if params["parent_object"]
            params["parent_object_id"] = params["parent_object"].id
            params.delete("parent_object")
          end

          if params["parent_item"]
            params["parent_item_id"] = params["parent_item"].id
            params.delete("parent_item")
          end

          if params["initiator"]
            params["initiator_id"] = params["initiator"].id
            params.delete("initiator")
          end

          result = @client.api_helper.get_response(Config::TODOIST_ACTIVITY_GET_COMMAND, params)
        end
    end
  end
end
