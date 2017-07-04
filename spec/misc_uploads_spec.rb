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
    @client = load_client  
  end
  
  it "is able to upload a file, find it, then delete it" do
    VCR.use_cassette("misc_uploads_is_able_to_upload_a_file_find_it_then_delete_it") do
      file = File.open("spec/template_sample.csv","r")
      added_file = @client.misc_uploads.add(file)
      expect(added_file["file_name"]).to be_truthy
      result = @client.misc_uploads.get()
      expect(result).to be_truthy
      @client.misc_uploads.delete(added_file["file_url"])
    end
  end

end
