require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Misc::Items do

  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "misc_quick"
  end  

  before do
    @misc_quick_manager = Todoist::Misc::Quick.new
    @items_manager = Todoist::Sync::Items.new
  end
  
  it "is able to quick add an item" do
    VCR.use_cassette("quick_is_able_to_quick_add_an_item") do
      item = @misc_quick_manager.add_item("Test quick add content today")
      expect(item).to be_truthy
      expect(item.due_date_utc).to be_truthy
      @items_manager.delete([item])
      Todoist::Util::CommandSynchronizer.sync
    end
  end
  
end
