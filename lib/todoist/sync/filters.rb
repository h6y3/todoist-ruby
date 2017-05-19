

module Todoist
  module Sync
    class Filters
        include Todoist::Util  

        # Return a Hash of filters where key is the id of a filter and value is a filter
        def collection
          return ApiHelper.collection("filters")
        end

        # Add a filter with a given hash of attributes and returns the filter id.  
        # Please note that item_id is required as is a date as specific in the
        # documentation.  This method can be tricky to all.
        def add(args)
          return ApiHelper.add(args, "filter_add")
        end

        # Update a filter given a filter
        def update(filter)
          return ApiHelper.command(filter.to_h, "filter_update")
        end

        # Delete filter given an array of filters
        def delete(filter)
          args = {id: filter.id}
          return ApiHelper.command(args, "filter_delete")
        end
  
        # Update orders for an array of filters
        def update_multiple_orders(filters)
          args = {}
          filters.each do |filter|
            args[filter.id] = filter.item_order
          end
          args = {id_order_mapping: args.to_json}
          return ApiHelper.command(args, "filter_update_orders")
        end


    end
  end
end
