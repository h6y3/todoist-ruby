require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Misc::Projects do

  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "misc_projects"
  end  

  before do
    @client = load_client
  end
  
  it "is able to get archived projects" do
    VCR.use_cassette("misc_projects_is_able_to_get_archived_projects") do
      result = @client.misc_projects.get_archived_projects
      expect(result).to be_truthy
    end
  end

  it "is able to get project info and project data" do
    VCR.use_cassette("misc_projects_is_able_to_get_project_info_and_project_data") do
      # Create an item and a project
      item = @client.sync_items.add({content: "Item3"})   
      project = @client.sync_projects.add({name: "Project1"})
      @client.sync
      
      # Add a note to the project
      note = @client.sync_notes.add({content: "NoteForMiscProjectTest", project_id: project.id})
      
      # Move requires fully inflated object
      items_list =  @client.sync_items.collection
      item = items_list[item.id]
      
      # Move the item to the project
      @client.sync_items.move(item, project)
      
      
      @client.sync
      # Get project info
      result = @client.misc_projects.get_project_info(project)
      
      expect(result["project"]).to be_truthy
      expect(result["notes"]).to be_truthy
      
      # Get project data
      result = @client.misc_projects.get_project_data(project)
      expect(result["project"]).to be_truthy
      expect(result["items"]).to be_truthy

      # Clean up
      
      @client.sync_items.delete([item])
      @client.sync_projects.delete([project])
      @client.sync_notes.delete(note)
      @client.sync
    end
  end

end
