module Todoist
  module Sync
    

    class Projects
      include Todoist::Util  

      # Return a Hash of projects where key is the id of a project and value is a project
      def collection
        return ApiHelper.collection("projects")
      end

      # Add a project with a given hash of attributes and returns the project id
      def add(args)
        return ApiHelper.add(args, "project_add")
      end

      # Delete projects given an array of projects
      def delete(projects)
        project_ids = projects.collect { |project| project.id }   
        args = {ids: project_ids.to_json}
        return ApiHelper.command(args, "project_delete")
      end

      # Archive projects given an array of projects
      def archive(projects)
        project_ids = projects.collect { |project| project.id }   
        args = {ids: project_ids.to_json}
        return ApiHelper.command(args, "project_archive")
      end

      # Unarchive projects given an array of projects
      def unarchive(projects)
        project_ids = projects.collect { |project| project.id }   
        args = {ids: project_ids.to_json}
        return ApiHelper.command(args, "project_unarchive")
      end

      # Update project given a project
      def update(project)
        return ApiHelper.command(project.to_h, "project_update")
      end

      # Update orders and indents for an array of projects
      def update_multiple_orders_and_indents(projects)
        tuples = {}
        projects.each do |project|
          tuples[project.id] = [project.item_order, project.indent]
        end
        args = {ids_to_orders_indents: tuples.to_json}
        return ApiHelper.command(args, "project_update_orders_indents")
      end

    end
  end
end