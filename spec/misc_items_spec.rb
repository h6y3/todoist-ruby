require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Misc::Items do

  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "misc_items"
  end  

  before do
    @misc_items_manager = Todoist::Misc::Items.new
    @items_manager = Todoist::Sync::Items.new
  end
  
  it "is able to add and get an item" do
    VCR.use_cassette("misc_items_is_able_to_add_and_get_an_item") do
      item = @misc_items_manager.add_item("Test quick add content")
      expect(item).to be_truthy
      
      item_data = @misc_items_manager.get_item(item)
      expect(item_data["item"]).to be_truthy
      @items_manager.delete([item])
      Todoist::Util::CommandSynchronizer.sync
    end
  end

  

end
