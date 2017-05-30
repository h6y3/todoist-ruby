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
    @notes_manager = Todoist::Sync::Notes.new
    @items_manager = Todoist::Sync::Items.new
  end

  it "is able to get notes" do
    VCR.use_cassette("notes_is_able_to_get_notes") do
      notes = @notes_manager.collection
      expect(notes).to be_truthy
    end
  end

  it "is able to add and update note" do  
    VCR.use_cassette("notes_is_able_to_add_and_update_note") do
      note_item = @items_manager.add({content: "ItemForNoteTest"}) 
      add_note = @notes_manager.add({content: "NoteForItemNoteTest", item_id: note_item.id})      
      expect(add_note).to be_truthy
      notes_list =  @notes_manager.collection
      queried_object = notes_list[add_note.id]
      expect(queried_object.item_id).to eq(note_item.id)
      expect(queried_object.content).to eq("NoteForItemNoteTest")
      queried_object.content = "NoteForItemNoteTestUpdate"
      @notes_manager.update({id: queried_object.id, content: "NoteForItemNoteTestUpdate"})
      notes_list =  @notes_manager.collection
      queried_object = notes_list[queried_object.id]
      expect(queried_object.content).to eq("NoteForItemNoteTestUpdate")
      
      @items_manager.delete([note_item])
      @notes_manager.delete(add_note)
      Todoist::Util::CommandSynchronizer.sync  
      
    end
  end
  
end
