module Todoist
  module Misc
    class Quick < Todoist::Service
        include Todoist::Util 

        # Implementation of the Quick Add Task available in the official 
        # clients.
        def add_item(text)
          result = @api_helper.get_response(Config::TODOIST_QUICK_ADD_COMMAND, {text: text})
          return ParseHelper.make_object(result)
        end

    end
  end
end