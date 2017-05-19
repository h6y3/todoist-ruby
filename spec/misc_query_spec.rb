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
    @query_manager = Todoist::Misc::Query.new
  end
  
  it "is able to query" do
    VCR.use_cassette("misc_query_is_able_to_query") do
      result = @query_manager.queries(["p1", "tomorrow"])
      expect(result["p1"]).to be_truthy
      result = @query_manager.query("tomorrow")
      expect(result).to be_truthy
    end
  end

end
