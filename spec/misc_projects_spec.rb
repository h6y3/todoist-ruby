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
    @misc_projects_manager = Todoist::Misc::Projects.new
    @notes_manager = Todoist::Sync::Notes.new
    @items_manager = Todoist::Sync::Items.new
    @projects_manager = Todoist::Sync::Projects.new
  end
  
  it "is able to get archived projects" do
    VCR.use_cassette("misc_projects_is_able_to_get_archived_projects") do
      result = @misc_projects_manager.get_archived_projects
      expect(result).to be_truthy
    end
  end

  it "is able to get project info and project data" do
    VCR.use_cassette("misc_projects_is_able_to_get_project_info_and_project_data") do
      # Create an item and a project
      item = @items_manager.add({content: "Item3"})   
      project = @projects_manager.add({name: "Project1"})
      Todoist::Util::CommandSynchronizer.sync
      
      # Add a note to the project
      note = @notes_manager.add({content: "NoteForMiscProjectTest", project_id: project.id})
      
      # Move requires fully inflated object
      items_list =  @items_manager.collection
      item = items_list[item.id]
      
      # Move the item to the project
      @items_manager.move(item, project)
      
      
      Todoist::Util::CommandSynchronizer.sync
      # Get project info
      result = @misc_projects_manager.get_project_info(project)
      
      expect(result["project"]).to be_truthy
      expect(result["notes"]).to be_truthy
      
      # Get project data
      result = @misc_projects_manager.get_project_data(project)
      expect(result["project"]).to be_truthy
      expect(result["items"]).to be_truthy

      # Clean up
      
      @items_manager.delete([item])
      @projects_manager.delete([project])
      @notes_manager.delete(note)
      Todoist::Util::CommandSynchronizer.sync
    end
  end

end
