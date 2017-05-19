require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Sync::Filters do
  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "filters"
  end  

  before do
    @filters_manager = Todoist::Sync::Filters.new
    @items_manager = Todoist::Sync::Items.new
  end

  it "is able to get filters" do
    VCR.use_cassette("filters_is_able_to_get_filters") do
      filters = @filters_manager.collection
      expect(filters).to be_truthy
    end
  end

  it "is able to add and update filter" do  
    VCR.use_cassette("filters_is_able_to_add_and_update_filter") do

      add_filter = @filters_manager.add({name: "FilterTest", query: "tomorrow"})
      expect(add_filter).to be_truthy
      filters_list =  @filters_manager.collection
      queried_object = filters_list[add_filter.id]
      expect(queried_object.name).to eq("FilterTest")
      queried_object.name = "FilterTestUpdate"
      @filters_manager.update(queried_object)
      filters_list =  @filters_manager.collection
      queried_object = filters_list[queried_object.id]
      expect(queried_object.name).to eq("FilterTestUpdate")
      
      @filters_manager.delete(add_filter)
      Todoist::Util::CommandSynchronizer.sync  
      
    end
  end
  
end
