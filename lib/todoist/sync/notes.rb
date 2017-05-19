module Todoist
  module Sync
    class Notes
        include Todoist::Util  

        # Return a Hash of notes where key is the id of a note and value is a note
        def collection
          return ApiHelper.collection("notes")
        end

        # Add a note with a given hash of attributes and returns the note id.  
        # Please note that item_id or project_id key is required.  In addition, 
        # content is also a required key in the hash.
        def add(args)
          return ApiHelper.add(args, "note_add")
        end

        # Update a note given a note
        def update(note)
          return ApiHelper.command(note.to_h, "note_update")
        end

        # Delete notes given an a note
        def delete(note)
          args = {id: note.id}
          return ApiHelper.command(args, "note_delete")
        end

      
    end
  end
end
