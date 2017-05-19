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
    @projects_manager = Todoist::Sync::Projects.new
    @templates_manager = Todoist::Misc::Templates.new
  end
  
  it "is able to import into a project" do
    VCR.use_cassette("templates_is_able_to_import_into_a_project") do
      project = @projects_manager.add({name: "TemplatesImport"})
      @projects_manager.collection
      file = File.open("spec/template_sample.csv","r")
      result = @templates_manager.import_into_project(project, file)
      expect(result).to be_truthy
      @projects_manager.delete([project])
      Todoist::Util::CommandSynchronizer.sync
    end
  end

  it "is able to export as a file" do
    VCR.use_cassette("templates_is_able_to_export_as_a_file") do
      project = @projects_manager.add({name: "TemplatesExport"})
      @projects_manager.collection
      file = @templates_manager.export_as_file(project)
      expect(file).to include("TYPE,CONTENT,PRIORITY,INDENT,AUTHOR,RESPONSIBLE,DATE,DATE_LANG,TIMEZONE")
      @projects_manager.delete([project])
      Todoist::Util::CommandSynchronizer.sync
    end
  end

  it "is able to export as a url" do  
    VCR.use_cassette("templates_is_able_to_export_as_a_url") do    
     project = @projects_manager.add({name: "TemplatesExport"})
      @projects_manager.collection
      result = @templates_manager.export_as_url(project)
      expect(result["file_name"]).to be_truthy
      @projects_manager.delete([project])
      Todoist::Util::CommandSynchronizer.sync
    end
  end

  
end
