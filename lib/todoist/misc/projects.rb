module Todoist
  module Misc
    class Projects < Todoist::Service
        include Todoist::Util  
        
        # Get archived projects.  Returns projects as documented here.
        def get_archived_projects()
          result = @client.api_helper.get_response(Config::TODOIST_PROJECTS_GET_ARCHIVED_COMMAND)
          return ParseHelper.make_objects_as_hash(result)
        end
        
        # Gets project information including all notes.
        
        def get_project_info(project, all_data = true)
          result = @client.api_helper.get_response(Config::TODOIST_PROJECTS_GET_COMMAND, {project_id: project.id, all_data: true})
          
          project = result["project"] ? ParseHelper.make_object(result["project"]) : nil
          notes = result["notes"] ? ParseHelper.make_objects_as_hash(result["notes"]) : nil
          return {"project" => project, "notes" => notes}
        end
        
        # Gets a project's uncompleted items
        def get_project_data(project)
          result = @client.api_helper.get_response(Config::TODOIST_PROJECTS_GET_DATA_COMMAND, {project_id: project.id})
          project = result["project"] ? ParseHelper.make_object(result["project"]) : nil
          items = result["items"] ? ParseHelper.make_objects_as_hash(result["items"]) : nil
          return {"project" => project, "items" => items}
        end
    end
  end
end
