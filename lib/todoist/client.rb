module Todoist
    class Client    

      def self.create_client_by_token(token)
        client = Client.new
        client.token = token 
        client
      end

      # TODO:  Need to write a unit test for this
      def self.create_client_by_login(email, password)
        client = Client.new
        result = api_helper.get_response(Config::TODOIST_USER_LOGIN_COMMAND, {email: email, password: password}, false)
        user = ParseHelper.make_object(result)
        client.token = user.token
        client
      end

      def token=(token)
        @token = token
      end
      
      def token
        @token
      end
      
      def sync
        @api_helper.sync
      end

      def misc_activity
        @misc_activity = Todoist::Misc::Activity.new(self) unless @misc_activity
        @misc_activity
      end

      def misc_backups
        @misc_backups = Todoist::Misc::Backups.new(self) unless @misc_backups
        @misc_backups
      end

      def misc_completed
        @misc_completed = Todoist::Misc::Completed.new(self) unless @misc_completed
        @misc_completed
      end

      def misc_items
        @misc_items = Todoist::Misc::Items.new(self) unless @misc_items
        @misc_items
      end

      def misc_projects
        @misc_projects = Todoist::Misc::Projects.new(self) unless @misc_projects
        @misc_projects
      end

      def misc_query
        @misc_query = Todoist::Misc::Query.new(self) unless @misc_query
        @misc_query
      end

      def misc_quick
        @misc_quick = Todoist::Misc::Quick.new(self) unless @misc_quick
        @misc_quick
      end

      def misc_templates
        @misc_templates = Todoist::Misc::Templates.new(self) unless @misc_templates
        @misc_templates
      end

      def misc_uploads
        @misc_uploads = Todoist::Misc::Uploads.new(self) unless @misc_uploads
        @misc_uploads
      end

      def sync_filters
        @sync_filters = Todoist::Sync::Filters.new(self) unless @sync_filters
        @sync_filters
      end

      def sync_items
        @sync_items = Todoist::Sync::Items.new(self) unless @sync_items
        @sync_items
      end

      def sync_labels
        @sync_labels = Todoist::Sync::Labels.new(self) unless @sync_labels
        @sync_labels
      end

      def sync_notes
        @sync_notes = Todoist::Sync::Notes.new(self) unless @sync_notes
        @sync_notes
      end

      def sync_projects
        @sync_projects = Todoist::Sync::Projects.new(self) unless @sync_projects
        @sync_projects
      end

      def sync_reminders
        @sync_reminders = Todoist::Sync::Reminders.new(self) unless @sync_reminders
        @sync_reminders
      end

      def api_helper
        @api_helper
      end

      protected

      def initialize
        @api_helper = Todoist::Util::ApiHelper.new(self)
      end
      


    end
end
