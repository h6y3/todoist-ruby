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
    @misc_activity_manager = Todoist::Misc::Activity.new
  end
  
  it "is able to get activity" do
    VCR.use_cassette("misc_activity_is_able_to_get_activity") do
      result = @misc_activity_manager.get
      expect(result).to be_truthy
    end
  end

end
