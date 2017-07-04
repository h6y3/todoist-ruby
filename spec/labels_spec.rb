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
    @client = load_client  
  end



  it "is able to get labels" do
    VCR.use_cassette("labels_is_able_to_get_labels") do
      labels = @client.sync_labels.collection
      expect(labels).to be_truthy
    end
  end

  it "is able to update a label" do  
    VCR.use_cassette("labels_is_able_to_update_a_label") do
      
      update_label = @client.sync_labels.add({name: "Labels3"})      
      expect(update_label).to be_truthy
      update_label.color = 2
      result = @client.sync_labels.update({id: update_label.id, color: update_label.color})
      expect(result).to be_truthy
      labels_list =  @client.sync_labels.collection
      queried_object = labels_list[update_label.id]
      expect(queried_object.color).to eq(2)
      @client.sync_labels.delete(update_label)
      @client.sync  
      
    end
  end

  it "is able to update multiple orders" do
    VCR.use_cassette("labels_is_able_to_update_multiple_orders") do
      # Add the various labels
      label = @client.sync_labels.add({name: "Label3"})
      expect(label).to be_truthy
      label2 = @client.sync_labels.add({name: "Label2"})
      
      # Restore the label fully
  
      label_collection = @client.sync_labels.collection
  
      label = label_collection[label.id]
      label2 = label_collection[label2.id]
      # Keep track of original values
      label_order = label.item_order
      label_order2 = label2.item_order
  
      # Swap orders
      label.item_order = label_order2
      label2.item_order = label_order
  
  
      @client.sync_labels.update_multiple_orders([label, label2])
      label_collection = @client.sync_labels.collection
  
      # Check to make sure newly retrieved object values match old ones
  
      expect(label_collection[label.id].item_order).to eq(label_order2)
      expect(label_collection[label2.id].item_order).to eq(label_order)
  
      # Clean up extra label
  
      @client.sync_labels.delete(label2)
      @client.sync_labels.delete(label)
      @client.sync
    end
  end
  
end
