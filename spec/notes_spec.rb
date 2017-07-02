require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Sync::Notes do
  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "notes"
  end  

  before do
    @client = load_client  
  end

  it "is able to get notes" do
    VCR.use_cassette("notes_is_able_to_get_notes") do
      notes = @client.sync_notes.collection
      expect(notes).to be_truthy
    end
  end

  it "is able to add and update note" do  
    VCR.use_cassette("notes_is_able_to_add_and_update_note") do
      note_item = @client.sync_items.add({content: "ItemForNoteTest"}) 
      add_note = @client.sync_notes.add({content: "NoteForItemNoteTest", item_id: note_item.id})      
      expect(add_note).to be_truthy
      notes_list =  @client.sync_notes.collection
      queried_object = notes_list[add_note.id]
      expect(queried_object.item_id).to eq(note_item.id)
      expect(queried_object.content).to eq("NoteForItemNoteTest")
      queried_object.content = "NoteForItemNoteTestUpdate"
      @client.sync_notes.update({id: queried_object.id, content: "NoteForItemNoteTestUpdate"})
      notes_list =  @client.sync_notes.collection
      queried_object = notes_list[queried_object.id]
      expect(queried_object.content).to eq("NoteForItemNoteTestUpdate")
      
      @client.sync_items.delete([note_item])
      @client.sync_notes.delete(add_note)
      Todoist::Util::CommandSynchronizer.sync  
      
    end
  end
  
end
