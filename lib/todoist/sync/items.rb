module Todoist
  module Sync
    class Items
        include Todoist::Util  

        # Return a Hash of items where key is the id of a item and value is a item
        def collection
          return ApiHelper.collection("items")
        end

        # Add a item with a given hash of attributes and returns the item id
        def add(args)
          return ApiHelper.add(args, "item_add")
        end

        # Update item given a item
        def update(item)
          return ApiHelper.command(item.to_h, "item_update")
        end

        # Delete items given an array of items
        def delete(items)
          item_ids = items.collect { |item| item.id }   
          args = {ids: item_ids.to_json}
          return ApiHelper.command(args, "item_delete")
        end

        # Move an item from one project to another project given an item and a project.
        # Note that move requires a fully inflated item object because it uses
        # the project id in the item object.
        def move(item, project)
          project_items = {item.project_id => [item.id]}
          args = {project_items: project_items, to_project: project.id}
          return ApiHelper.command(args, "item_move")
        end
        
        # Complete items and optionally move them to history given an array of items.  When force_history = 1,  items should be moved to history (where 1 is true and 0 is false, and the default is 1) This is useful when checking off sub items.
        
        def complete(items, force_history=1)
          item_ids = items.collect { |item| item.id }   
          args = {ids: item_ids.to_json, force_history: force_history}
          return ApiHelper.command(args, "item_complete")
        end
        
        # Uncomplete items and move them to the active projects given an array 
        # of items.
        
        def uncomplete(items)
          item_ids = items.collect { |item| item.id }   
          args = {ids: item_ids.to_json}
          return ApiHelper.command(args, "item_uncomplete")
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
            args["new_date_utc"] = ParseHelper.formatTime(new_date_utc)
          end
          
          if date_string
            args["date_string"] = date_string
          end
          
          return ApiHelper.command(args, "item_update_date_complete")
        end
        
        # A simplified version of item_complete / item_update_date_complete. 
        # The command does exactly what official clients do when you close a item 
        # given an item.
        
        def close(item)
          args = {id: item.id}
          return ApiHelper.command(args, "item_close")
        end
        
        # Update the day orders of multiple items at once given an array of 
        # items
        def update_day_orders(items)
          ids_to_orders = {}
          items.each do |item|
            ids_to_orders[item.id] = item.day_order
          end
          args = {ids_to_orders: ids_to_orders.to_json}
          return ApiHelper.command(args, "item_update_day_orders")
        end
        
        # Update orders and indents for an array of items
        def update_multiple_orders_and_indents(items)
          tuples = {}
          items.each do |item|
            tuples[item.id] = [item.item_order, item.indent]
          end
          args = {ids_to_orders_indents: tuples.to_json}
          return ApiHelper.command(args, "item_update_orders_indents")
        end
      
    end
  end
end
