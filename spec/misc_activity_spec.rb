require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Misc::Activity do

  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "misc_activity"
  end  

  before do
    @client = load_client  
  end
  
  it "is able to get activity" do
    VCR.use_cassette("misc_activity_is_able_to_get_activity") do
      result = @client.misc_activity.get
      expect(result).to be_truthy
    end
  end

end
