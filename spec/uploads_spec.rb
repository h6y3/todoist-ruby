require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Misc::Uploads do

  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "uploads"
  end  

  before do
    @uploads_manager = Todoist::Misc::Uploads.new
  end
  
  it "is able to upload a file, find it, then delete it" do
    VCR.use_cassette("uploads_is_able_to_upload_a_file_find_it_then_delete_it") do
      file = File.open("spec/template_sample.csv","r")
      added_file = @uploads_manager.add(file)
      expect(added_file["file_name"]).to be_truthy
      result = @uploads_manager.get()
      expect(result).to be_truthy
      @uploads_manager.delete(added_file["file_url"])
    end
  end

end
