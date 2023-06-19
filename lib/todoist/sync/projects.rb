module Todoist
  module Sync
    

    class Projects < Todoist::Service
      include Todoist::Util  

      # Return a Hash of projects where key is the id of a project and value is a project
      def collection
        return @client.api_helper.collection("projects")
      end

      # Add a project with a given hash of attributes and returns the project id
      def add(args)
        return @client.api_helper.add(args, "project_add")
      end

      # Delete a project given a project id
      def delete(project_id)
        args = {id: project_id}
        return @client.api_helper.command(args, "project_delete")
      end

      # Archive projects given an array of projects
      def archive(projects)
        project_ids = projects.collect { |project| project.id }   
        args = {ids: project_ids.to_json}
        return @client.api_helper.command(args, "project_archive")
      end

      # Unarchive projects given an array of projects
      def unarchive(projects)
        project_ids = projects.collect { |project| project.id }   
        args = {ids: project_ids.to_json}
        return @client.api_helper.command(args, "project_unarchive")
      end

      # Update project given a hash of attributes
      def update(args)
        return @client.api_helper.command(args, "project_update")
      end

      # Update orders and indents for an array of projects
      def update_multiple_orders_and_indents(projects)
        tuples = {}
        projects.each do |project|
          tuples[project.id] = [project.item_order, project.indent]
        end
        args = {ids_to_orders_indents: tuples.to_json}
        return @client.api_helper.command(args, "project_update_orders_indents")
      end

    end
  end
end