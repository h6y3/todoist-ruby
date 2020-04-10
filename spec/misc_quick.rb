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
    @client = load_client
  end

  it "is able to quick add an item" do
    VCR.use_cassette("misc_quick_is_able_to_quick_add_an_item") do
      item = @client.misc_quick.add_item("Test quick add content today")
      expect(item).to be_truthy
      expect(item.due).to be_truthy
      @client.sync_items.delete([item])
      @client.sync
    end
  end

end
