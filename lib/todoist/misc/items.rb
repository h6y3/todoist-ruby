module Todoist
  module Misc
    class Items < Todoist::Service
        include Todoist::Util  
        
        # Add a new task to a project. Note, that this is provided as a
        # helper method, a shortcut, to quickly add a task without going 
        # through the Sync workflow.  
        # This method takes content as well as an array of optional params as
        # detailed here:  https://developer.todoist.com/#add-item.
        # 
        # If adding labels, use the key "labels" and input an array of label 
        # objects.  For project, add a project object.
        #
        # Critically, collaboration features are not supported by this library
        # so assigned_by_uid and responsible_uid are not implemented.
        
        def add_item(content, optional_params = {})
          params = {content: content}
          if optional_params["project"]
            params["project_id"] = project.id
            optional_params.delete("project")
          end
          
          if optional_params["labels"]
            labels = optional_params["labels"]
            labels_param = labels.collect { |label| label.id }   
            params["labels"] = labels_param.to_json
            optional_params.delete("labels")
          end

          params.merge(optional_params)
          result = @client.api_helper.get_response(Config::TODOIST_ITEMS_ADD_COMMAND, params)
          item = ParseHelper.make_object(result)
          return item
        end
        
        # This function is used to extract detailed information about the item, 
        # including all the notes. It’s especially important, because on initial 
        # load we return back no more than 10 last notes.
        # 
        # For more information see: https://developer.todoist.com/#get-item-info
        def get_item(item, all_data = true)
          params = {item_id: item.id, all_data: all_data}
          
          result = @client.api_helper.get_response(Config::TODOIST_ITEMS_GET_COMMAND, params)
          item = ParseHelper.make_object(result["item"])
          project = ParseHelper.make_object(result["project"])
          notes = result["notes"] ? ParseHelper.make_objects_as_hash(result["notes"]) : nil
          return {"item" => item, "project" => project, "notes" => notes}
        end
        
    end
  end
end
