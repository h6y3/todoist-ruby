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
    @client = load_client  
  end
  
  it "is able to add and get an item" do
    VCR.use_cassette("misc_items_is_able_to_add_and_get_an_item") do
      item = @client.misc_items.add_item("Test quick add content")
      expect(item).to be_truthy
      
      item_data = @client.misc_items.get_item(item)
      @client.sync_items.delete([item])
      @client.sync
    end
  end

  

end
