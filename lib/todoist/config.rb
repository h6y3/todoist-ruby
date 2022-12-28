module Todoist
  class Config
    TODOIST_API_URL = "https://api.todoist.com/sync/v9"

    # List of commands supported
    @@command_list = [
      TODOIST_SYNC_COMMAND = "/sync",
      TODOIST_TEMPLATES_IMPORT_INTO_PROJECT_COMMAND = "/templates/import_into_project",
      TODOIST_TEMPLATES_EXPORT_AS_FILE_COMMAND = "/templates/export_as_file",
      TODOIST_TEMPLATES_EXPORT_AS_URL_COMMAND = "/templates/export_as_url",
      TODOIST_UPLOADS_ADD_COMMAND = "/uploads/add",
      TODOIST_UPLOADS_GET_COMMAND = "/uploads/get",
      TODOIST_UPLOADS_DELETE_COMMAND = "/uploads/delete",
      TODOIST_COMPLETED_GET_STATS_COMMAND = "/completed/get_stats",
      TODOIST_COMPLETED_GET_ALL_COMMAND = "/completed/get_all",
      TODOIST_PROJECTS_GET_ARCHIVED_COMMAND = "/projects/get_archived",
      TODOIST_PROJECTS_GET_COMMAND = "/projects/get",
      TODOIST_PROJECTS_GET_DATA_COMMAND = "/projects/get_data",
      TODOIST_ITEMS_ADD_COMMAND = "/items/add",
      TODOIST_ITEMS_GET_COMMAND = "/items/get",
      TODOIST_QUICK_ADD_COMMAND = "/quick/add",
      TODOIST_ACTIVITY_GET_COMMAND = "/activity/get",
      TODOIST_BACKUPS_GET_COMMAND = "/backups/get",
      TODOIST_USER_LOGIN_COMMAND = "/user/login"
    ]

    # Map of commands to URIs
    @@uri = nil

    # Artificial delay between requests to avoid API throttling
    @@delay_between_requests = 0

    # Should API throttling happen (HTTP Error 429), retry_time between requests
    # with exponential backoff
    @@retry_time = 20

    def self.retry_time=(retry_time)
      @@retry_time = retry_time
    end

    def self.retry_time
      @@retry_time
    end

    def self.delay_between_requests=(delay_between_requests)
      @@delay_between_requests = delay_between_requests
    end

    def self.delay_between_requests
      @@delay_between_requests
    end

    def self.getURI
      if @@uri == nil
        @@uri = {}
        @@command_list.each do |command|
          @@uri[command] =  URI.parse(TODOIST_API_URL + command)
        end
      end
      return @@uri
    end

  end
end
