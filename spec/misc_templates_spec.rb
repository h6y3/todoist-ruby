require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Misc::Templates do

  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "templates"
  end  

  before do
    @client = load_client  
  end
  
  it "is able to import into a project" do
    VCR.use_cassette("misc_templates_is_able_to_import_into_a_project") do
      project = @client.sync_projects.add({name: "TemplatesImport"})
      @client.sync_projects.collection
      file = File.open("spec/template_sample.csv","r")
      result = @client.misc_templates.import_into_project(project, file)
      expect(result).to be_truthy
      @client.sync_projects.delete([project])
      @client.sync
    end
  end

  it "is able to export as a file" do
    VCR.use_cassette("misc_templates_is_able_to_export_as_a_file") do
      project = @client.sync_projects.add({name: "TemplatesExport"})
      @client.sync_projects.collection
      file = @client.misc_templates.export_as_file(project)
      expect(file).to include("TYPE,CONTENT,DESCRIPTION,PRIORITY,INDENT,AUTHOR,RESPONSIBLE,DATE,DATE_LANG,TIMEZONE")
      @client.sync_projects.delete([project])
      @client.sync
    end
  end

  it "is able to export as a url" do  
    VCR.use_cassette("misc_templates_is_able_to_export_as_a_url") do    
     project = @client.sync_projects.add({name: "TemplatesExport"})
      @client.sync_projects.collection
      result = @client.misc_templates.export_as_url(project)
      expect(result["file_name"]).to be_truthy
      @client.sync_projects.delete([project])
      @client.sync
    end
  end

  
end
