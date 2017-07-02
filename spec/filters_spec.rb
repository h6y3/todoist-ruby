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
    @client = load_client    
  end

  it "is able to get filters" do
    VCR.use_cassette("filters_is_able_to_get_filters") do
      filters = @client.sync_filters.collection
      expect(filters).to be_truthy
    end
  end

  it "is able to add and update filter" do  
    VCR.use_cassette("filters_is_able_to_add_and_update_filter") do

      add_filter = @client.sync_filters.add({name: "FilterTest", query: "tomorrow"})
      expect(add_filter).to be_truthy
      filters_list =  @client.sync_filters.collection
      queried_object = filters_list[add_filter.id]
      expect(queried_object.name).to eq("FilterTest")
      queried_object.name = "FilterTestUpdate"
      @client.sync_filters.update({id: queried_object.id, name: queried_object.name})
      filters_list =  @client.sync_filters.collection
      queried_object = filters_list[queried_object.id]
      expect(queried_object.name).to eq("FilterTestUpdate")
      
      @client.sync_filters.delete(add_filter)
      Todoist::Util::CommandSynchronizer.sync  
      
    end
  end
  
end
