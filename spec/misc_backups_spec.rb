require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Misc::Backups do

  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "misc_backups"
  end  

  before do
    @client = load_client
  end
  
  it "is able to get backups" do
    VCR.use_cassette("misc_backups_is_able_to_get_backups") do
      result = @client.misc_backups.get
      expect(result).to be_truthy
    end
  end

end
