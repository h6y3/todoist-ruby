module Todoist
  module Misc
    class Quick
        include Todoist::Util 

        # Implementation of the Quick Add Task available in the official 
        # clients.
        def add_item(text)
          result = NetworkHelper.getResponse(Config::TODOIST_QUICK_ADD_COMMAND, {text: text})
          return ParseHelper.make_object(result)
        end

    end
  end
end