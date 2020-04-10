module Todoist
  module Sync
    class Items < Todoist::Service
        include Todoist::Util

        # Return a Hash of items where key is the id of a item and value is a item
        def collection
          return @client.api_helper.collection("items")
        end

        # Add a item with a given hash of attributes and returns the item id
        def add(args)
          return @client.api_helper.add(args, "item_add")
        end

        # Update item given a hash of attributes
        def update(args)
          return @client.api_helper.command(args, "item_update")
        end

        # Delete items given an array of items
        def delete(items)
          item_ids = items.collect { |item| item.id }
          args = {ids: item_ids.to_json}
          return @client.api_helper.command(args, "item_delete")
        end

        # Move an item from one project to another project given an item and a project.
        # Note that move requires a fully inflated item object because it uses
        # the project id in the item object.
        def move(item, project)
          args = {id: item.id, project_id: project.id}
          return @client.api_helper.command(args, "item_move")
        end

        # Complete an item and optionally move them to history.  When force_history = 1,  items should be moved to history (where 1 is true and 0 is false, and the default is 1) This is useful when checking off sub items.

        def complete(item, force_history=1)
          args = {id: item.id, force_history: force_history}
          return @client.api_helper.command(args, "item_complete")
        end

        # Uncomplete item and move them to the active projects

        def uncomplete(item)
          args = {id: item.id}
          return @client.api_helper.command(args, "item_uncomplete")
        end

        # Complete a recurring item given the id of the recurring item.
        # This method also accepts as optional a new DateTime in UTC, a date
        # string to reset the object to, and whether or not the item is to
        # be completed or not using the is_forward flag.

        def complete_recurring(item, new_date_utc = nil, date_string = nil,
          is_forward = 1)

          args = {id: item.id, is_forward: is_forward}
          if new_date_utc
             # Reformat DateTime to the following string:  YYYY-MM-DDTHH:MM
            args["due"] = {date: ParseHelper.format_time(new_date_utc)}
          end

          if date_string
            args["due"] = {string: date_string}
          end

          return @client.api_helper.command(args, "item_update_date_complete")
        end

        # A simplified version of item_complete / item_update_date_complete.
        # The command does exactly what official clients do when you close a item
        # given an item.

        def close(item)
          args = {id: item.id}
          return @client.api_helper.command(args, "item_close")
        end

        # Update the day orders of multiple items at once given an array of
        # items
        def update_day_orders(items)
          ids_to_orders = {}
          items.each do |item|
            ids_to_orders[item.id] = item.day_order
          end
          args = {ids_to_orders: ids_to_orders.to_json}
          return @client.api_helper.command(args, "item_update_day_orders")
        end

        # Update orders and indents for an array of items
        def update_multiple_orders_and_indents(items)
          tuples = {}
          items.each do |item|
            tuples[item.id] = [item.item_order, item.indent]
          end
          args = {ids_to_orders_indents: tuples.to_json}
          return @client.api_helper.command(args, "item_update_orders_indents")
        end

    end
  end
end
