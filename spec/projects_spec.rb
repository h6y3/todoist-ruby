require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Sync::Projects do

  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "projects"
  end  

  before do
    @projects_manager = Todoist::Sync::Projects.new
    @project = @projects_manager.add({name: "Project1"})
  end

  after do
    VCR.use_cassette("projects_after") do    
      @projects_manager.delete([@project])
      Todoist::Util::CommandSynchronizer.sync
    end
  end  

  it "is able to get projects" do
    VCR.use_cassette("projects_is_able_to_get_projects") do
      projects = @projects_manager.collection
      expect(projects).to be_truthy
    end
  end

  it "is able to archive and unarchive projects" do
    VCR.use_cassette("projects_is_able_to_archive_and_unarchive_projects") do
      expect(@project).to be_truthy
      result = @projects_manager.archive([@project])
      expect(result).to be_truthy
      result = @projects_manager.unarchive([@project])
      expect(result).to be_truthy
    end
  end

  it "is able to update a project" do  
    VCR.use_cassette("projects_is_able_to_update_a_project") do    
      update_project = @projects_manager.add({name: "Project4"})
      update_project.indent = 2
      result = @projects_manager.update(id: update_project.id, indent: update_project.indent)
      expect(result).to be_truthy
      queried_object = @projects_manager.collection[update_project.id]
      expect(queried_object.indent).to eq(2)
      @projects_manager.delete([update_project])
      Todoist::Util::CommandSynchronizer.sync      
    end
  end

  it "is able to update multiple orders and indents" do
    VCR.use_cassette("projects_is_able_to_update_multiple_orders_and_indents") do
      expect(@project).to be_truthy
      project2 = @projects_manager.add({name: "Project2"})
  
      # Restore the projects fully
  
      project_collection = @projects_manager.collection
  
      @project = project_collection[@project.id]
      project2 = project_collection[project2.id]
  
  
      # Keep track of original values
      project_order = @project.item_order
      project_order2 = project2.item_order
  
      # Swap orders
      @project.item_order = project_order2
      project2.item_order = project_order
  
      # Indent @project
      @project.indent = 2
  
      @projects_manager.update_multiple_orders_and_indents([@project, project2])
      project_collection = @projects_manager.collection
  
      # Check to make sure newly retrieved object values match old ones
  
      expect(project_collection[@project.id].item_order).to eq(project_order2)
      expect(project_collection[project2.id].item_order).to eq(project_order)
      expect(project_collection[@project.id].indent).to eq(2)
  
      # Clean up extra project
  
      @projects_manager.delete([project2])
    end
    

  end
  
end
