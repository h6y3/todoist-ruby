module Todoist
  module Misc
    class Templates < Todoist::Service
        include Todoist::Util  
        
        # Given a project and a File object (Ruby) imports the content onto the
        # server.  Critically, if the file is a CSV file make sure that the 
        # suffix is CSV.  Otherwise, the file will be parsed as one item per line
        # and ignore the formatting altogether.
        def import_into_project(project, file)
          multipart_file = @client.api_helper.multipart_file(file)
          params = {project_id: project.id, file: multipart_file}
          @client.api_helper.get_multipart_response(Config::TODOIST_TEMPLATES_IMPORT_INTO_PROJECT_COMMAND, params)
        end
        
        # Export the project as a CSV string
        def export_as_file(project)
          params = {project_id: project.id}
          @client.api_helper.get_response(Config::TODOIST_TEMPLATES_EXPORT_AS_FILE_COMMAND, params)
        end
        
        # Export the project as a url that can be accessed over HTTP
        def export_as_url(project)
          params = {project_id: project.id}
          @client.api_helper.get_response(Config::TODOIST_TEMPLATES_EXPORT_AS_URL_COMMAND, params)
        end
    end
  end
end
