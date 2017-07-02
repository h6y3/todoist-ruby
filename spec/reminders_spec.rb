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
    @client = load_client
    @client.sync_reminders = Todoist::Sync::Reminders.new
    @client.sync_items = Todoist::Sync::Items.new
  end

  it "is able to get reminders" do
    VCR.use_cassette("reminders_is_able_to_get_reminders") do
      reminders = @client.sync_reminders.collection
      expect(reminders).to be_truthy
    end
  end

  it "is able to add and update reminder" do  
    VCR.use_cassette("reminders_is_able_to_add_and_update_reminder") do
      reminder_item = @client.sync_items.add({content: "ItemForReminderTest"}) 
      @client.sync_items.collection
      add_reminder = @client.sync_reminders.add({item_id: reminder_item.id, 
        service: "email", type: "absolute", due_date_utc: "2018-03-24T23:59"})
       expect(add_reminder).to be_truthy
      reminders_list =  @client.sync_reminders.collection
      queried_object = reminders_list[add_reminder.id]
      expect(queried_object.item_id).to eq(reminder_item.id)
      expect(queried_object.service).to eq("email")
      queried_object.service = "mobile"
      @client.sync_reminders.update({id: queried_object.id, service: queried_object.service})
      reminders_list =  @client.sync_reminders.collection
      queried_object = reminders_list[queried_object.id]
      expect(queried_object.service).to eq("mobile")
      
      @client.sync_items.delete([reminder_item])
      @client.sync_reminders.delete(add_reminder)
      Todoist::Util::CommandSynchronizer.sync  
      
    end
  end
  
end
