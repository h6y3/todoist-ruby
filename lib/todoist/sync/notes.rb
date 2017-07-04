module Todoist
  module Sync
    class Notes < Todoist::Service
        include Todoist::Util  

        # Return a Hash of notes where key is the id of a note and value is a note
        def collection
          return @client.api_helper.collection("notes")
        end

        # Add a note with a given hash of attributes and returns the note id.  
        # Please note that item_id or project_id key is required.  In addition, 
        # content is also a required key in the hash.
        def add(args)
          return @client.api_helper.add(args, "note_add")
        end

        # Update a note given a hash of attributes
        def update(args)
          return @client.api_helper.command(args, "note_update")
        end

        # Delete notes given an a note
        def delete(note)
          args = {id: note.id}
          return @client.api_helper.command(args, "note_delete")
        end

      
    end
  end
end
