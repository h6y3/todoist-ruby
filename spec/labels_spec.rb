require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Sync::Labels do
  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "labels"
  end  

  before do
    @labels_manager = Todoist::Sync::Labels.new
    @label = @labels_manager.add({name: "Label1"})
  end

  after do
    VCR.use_cassette("labels_after") do
      @labels_manager.delete(@label)
      Todoist::Util::CommandSynchronizer.sync
    end
  end  

  it "is able to get labels" do
    VCR.use_cassette("labels_is_able_to_get_labels") do
      labels = @labels_manager.collection
      expect(labels).to be_truthy
    end
  end

  it "is able to update a label" do  
    VCR.use_cassette("labels_is_able_to_update_a_label") do
      
      update_label = @labels_manager.add({name: "Labels3"})      
      expect(update_label).to be_truthy
      update_label.color = 2
      result = @labels_manager.update(update_label)
      expect(result).to be_truthy
      labels_list =  @labels_manager.collection
      queried_object = labels_list[update_label.id]
      expect(queried_object.color).to eq(2)
      @labels_manager.delete(update_label)
      Todoist::Util::CommandSynchronizer.sync  
      
    end
  end

  it "is able to update multiple orders" do
    VCR.use_cassette("labels_is_able_to_update_multiple_orders") do
      # Add the various labels
      label = @labels_manager.add({name: "Label3"})
      expect(label).to be_truthy
      label2 = @labels_manager.add({name: "Label2"})
      
      # Restore the label fully
  
      label_collection = @labels_manager.collection
  
      label = label_collection[label.id]
      label2 = label_collection[label2.id]
      # Keep track of original values
      label_order = label.item_order
      label_order2 = label2.item_order
  
      # Swap orders
      label.item_order = label_order2
      label2.item_order = label_order
  
  
      @labels_manager.update_multiple_orders([label, label2])
      label_collection = @labels_manager.collection
  
      # Check to make sure newly retrieved object values match old ones
  
      expect(label_collection[label.id].item_order).to eq(label_order2)
      expect(label_collection[label2.id].item_order).to eq(label_order)
  
      # Clean up extra label
  
      @labels_manager.delete(label2)
    end
  end
  
end
