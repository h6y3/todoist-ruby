require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Sync::Reminders do
  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "reminders"
  end  

  before do
    @reminders_manager = Todoist::Sync::Reminders.new
    @items_manager = Todoist::Sync::Items.new
  end

  it "is able to get reminders" do
    VCR.use_cassette("reminders_is_able_to_get_reminders") do
      reminders = @reminders_manager.collection
      expect(reminders).to be_truthy
    end
  end

  it "is able to add and update reminder" do  
    VCR.use_cassette("reminders_is_able_to_add_and_update_reminder") do
      reminder_item = @items_manager.add({content: "ItemForReminderTest"}) 
      @items_manager.collection
      add_reminder = @reminders_manager.add({item_id: reminder_item.id, 
        service: "email", type: "absolute", due_date_utc: "2018-03-24T23:59"})
       expect(add_reminder).to be_truthy
      reminders_list =  @reminders_manager.collection
      queried_object = reminders_list[add_reminder.id]
      expect(queried_object.item_id).to eq(reminder_item.id)
      expect(queried_object.service).to eq("email")
      queried_object.service = "mobile"
      @reminders_manager.update(queried_object)
      reminders_list =  @reminders_manager.collection
      queried_object = reminders_list[queried_object.id]
      expect(queried_object.service).to eq("mobile")
      
      @items_manager.delete([reminder_item])
      @reminders_manager.delete(add_reminder)
      Todoist::Util::CommandSynchronizer.sync  
      
    end
  end
  
end
