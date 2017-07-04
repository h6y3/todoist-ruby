module Todoist
  module Sync
    class Labels < Todoist::Service
        include Todoist::Util  

        # Return a Hash of labels where key is the id of a label and value is a label
        def collection
          return @client.api_helper.collection("labels")
        end

        # Add a label with a given hash of attributes and returns the label id
        def add(args)
          return @client.api_helper.add(args, "label_add")
        end

        # Update label given a hash of attributes
        def update(args)
          return @client.api_helper.command(args, "label_update")
        end

        # Delete a label given a label
        def delete(label)
          args = {id: label.id}
          return @client.api_helper.command(args, "label_delete")
        end

        # Update orders for an array of labels
        def update_multiple_orders(labels)
          args = {}
          labels.each do |label|
            args[label.id] = label.item_order
          end
          args = {id_order_mapping: args.to_json}
          return @client.api_helper.command(args, "label_update_orders")
        end

    end
  end
end
