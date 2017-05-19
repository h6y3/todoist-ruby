module Todoist
  module Sync
    class Labels
        include Todoist::Util  

        # Return a Hash of labels where key is the id of a label and value is a label
        def collection
          return ApiHelper.collection("labels")
        end

        # Add a label with a given hash of attributes and returns the label id
        def add(args)
          return ApiHelper.add(args, "label_add")
        end

        # Update label given a label
        def update(label)
          return ApiHelper.command(label.to_h, "label_update")
        end

        # Delete a label given a label
        def delete(label)
          args = {id: label.id}
          return ApiHelper.command(args, "label_delete")
        end

        # Update orders for an array of labels
        def update_multiple_orders(labels)
          args = {}
          labels.each do |label|
            args[label.id] = label.item_order
          end
          args = {id_order_mapping: args.to_json}
          return ApiHelper.command(args, "label_update_orders")
        end

    end
  end
end
