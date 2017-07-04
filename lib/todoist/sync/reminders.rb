module Todoist
  module Sync
    class Reminders < Todoist::Service
        include Todoist::Util  

        # Return a Hash of reminders where key is the id of a reminder and value is a reminder
        def collection
          return @client.api_helper.collection("reminders")
        end

        # Add a reminder with a given hash of attributes and returns the reminder id.  
        # Please note that item_id is required as is a date as specific in the
        # documentation.  This method can be tricky to all.
        def add(args)
          return @client.api_helper.add(args, "reminder_add")
        end

        # Update a reminder given a hash of attributes
        def update(args)
          return @client.api_helper.command(args, "reminder_update")
        end

        # Delete reminder given an array of reminders
        def delete(reminder)
          args = {id: reminder.id}
          return @client.api_helper.command(args, "reminder_delete")
        end

        # Clear locations which is used for location reminders
        def clear_locations
          args = {}
          return @client.api_helper.command(args, "clear_locations")
        end
    end
  end
end
