require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Misc::Query do

  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "misc_query"
  end  

  before do
    @client = load_client  
  end
  
  it "is able to query" do
    VCR.use_cassette("misc_query_is_able_to_query") do
      result = @client.misc_query.queries(["p1", "tomorrow"])
      expect(result["p1"]).to be_truthy
      result = @client.misc_query.query("tomorrow")
      expect(result).to be_truthy
    end
  end

end
