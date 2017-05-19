require "net/http"
require "json"
require "todoist/util/config"
require "todoist/util/network_helper"
require "todoist/util/parse_helper"
require "todoist/util/uuid"
require "todoist/util/command_synchronizer"
require "ostruct"
require 'concurrent'



module Todoist

  module Util

    class ApiHelper
      
      @@object_cache = {"projects" => Concurrent::Hash.new({}), "labels" => Concurrent::Hash.new({}), 
        "items" => Concurrent::Hash.new({}), "notes" => Concurrent::Hash.new({}),
        "reminders" => Concurrent::Hash.new({}), "filters" => Concurrent::Hash.new({})
      }
      @@sync_token_cache = Concurrent::Hash.new({"projects" => "*", "labels" => "*", 
        "items" => "*", "notes" => "*", "reminders" => "*", "filters" => "*"})

      def self.collection(type)
        CommandSynchronizer.sync
        
        response = getSyncResponse({sync_token: sync_token(type), resource_types: "[\"#{type}\"]"})
        response[type].each do |object_data|
           object = OpenStruct.new(object_data)
           objects(type)[object.id] = object
        end
        set_sync_token(type, response["sync_token"])
        return objects(type)
      end
      
      def self.exec(args, command, temporary_resource_id)
        command_uuid = Uuid.command_uuid
        commands = {type: command, temp_id: temporary_resource_id, uuid: command_uuid, args: args}
        response = getSyncResponse({commands: "[#{commands.to_json}]"})
        raise RuntimeError, "Response returned is not ok" unless response["sync_status"][command_uuid] == "ok"
        return response
      end
      
      def self.command(args, command)
        temporary_resource_id = Uuid.temporary_resource_id
        command_uuid = Uuid.command_uuid
        command = {type: command, temp_id: temporary_resource_id, uuid: command_uuid, args: args}
        CommandSynchronizer.queue(command)
        return true
      end

      def self.add(args, command)
        temporary_resource_id = Uuid.temporary_resource_id
        command_uuid = Uuid.command_uuid
        command = {type: command, temp_id: temporary_resource_id, uuid: command_uuid, args: args}
        object = OpenStruct.new({temp_id: temporary_resource_id, id: temporary_resource_id})
        temp_id_callback = Proc.new do |temp_id_mappings|
            object.id = temp_id_mappings[temporary_resource_id] if temp_id_mappings[temporary_resource_id]
        end
        
        CommandSynchronizer.queue(command, temp_id_callback)
        return object
      end

      def self.getSyncResponse(params)
        NetworkHelper.getResponse(Config::TODOIST_SYNC_COMMAND, params)
      end

      protected


      
      def self.objects(type)
        @@object_cache[type]
      end

      def self.sync_token(type)
        @@sync_token_cache[type]
      end

      def self.set_sync_token(type, value)
        @@sync_token_cache[type] = value
      end

    end
  end
end
