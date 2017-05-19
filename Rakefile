require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :spec do 
  desc "Delete VCR and pre-generated UUID files"
  task :clean_all do
    FileUtils.rm Dir.glob('fixtures/uuid/*.yml')
    FileUtils.rm Dir.glob('fixtures/vcr_cassettes/*.yml')
  end
  desc "Delete VCR and pre-generated UUID files for a specific resource"
  task :clean, [:resource] do |t, args|
    FileUtils.rm Dir.glob("fixtures/uuid/#{args[:resource]}*.yml")
    FileUtils.rm Dir.glob("fixtures/vcr_cassettes/#{args[:resource]}*.yml")
  end
end

