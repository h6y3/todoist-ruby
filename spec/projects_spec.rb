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
    @client = load_client  
   
  end

  it "is able to get projects" do
    VCR.use_cassette("projects_is_able_to_get_projects") do
      projects = @client.sync_projects.collection
      expect(projects).to be_truthy
    end
  end

  it "is able to archive and unarchive projects" do
    VCR.use_cassette("projects_is_able_to_archive_and_unarchive_projects") do
      project = @client.sync_projects.add({name: "Project1"})
      expect(project).to be_truthy
      result = @client.sync_projects.archive([project])
      expect(result).to be_truthy
      result = @client.sync_projects.unarchive([project])
      expect(result).to be_truthy
      @client.sync_projects.delete([project])
      @client.sync
    end
  end

  it "is able to update a project" do  
    VCR.use_cassette("projects_is_able_to_update_a_project") do    
      update_project = @client.sync_projects.add({name: "Project4"})
      update_project.indent = 2
      result = @client.sync_projects.update(id: update_project.id, indent: update_project.indent)
      expect(result).to be_truthy
      queried_object = @client.sync_projects.collection[update_project.id]
      expect(queried_object.indent).to eq(2)
      @client.sync_projects.delete([update_project])
      @client.sync      
    end
  end

  it "is able to update multiple orders and indents" do
    VCR.use_cassette("projects_is_able_to_update_multiple_orders_and_indents") do
      project = @client.sync_projects.add({name: "Project1"})
      expect(project).to be_truthy
      project2 = @client.sync_projects.add({name: "Project2"})
  
      # Restore the projects fully
  
      project_collection = @client.sync_projects.collection
  
      project = project_collection[project.id]
      project2 = project_collection[project2.id]
  
  
      # Keep track of original values
      project_order = project.item_order
      project_order2 = project2.item_order
  
      # Swap orders
      project.item_order = project_order2
      project2.item_order = project_order
  
      # Indent project
      project.indent = 2
  
      @client.sync_projects.update_multiple_orders_and_indents([project, project2])
      project_collection = @client.sync_projects.collection
  
      # Check to make sure newly retrieved object values match old ones
  
      expect(project_collection[project.id].item_order).to eq(project_order2)
      expect(project_collection[project2.id].item_order).to eq(project_order)
      expect(project_collection[project.id].indent).to eq(2)
  
      # Clean up extra project
  
      @client.sync_projects.delete([project2])
      @client.sync_projects.delete([project])
      @client.sync
    end
    

  end
  
end
