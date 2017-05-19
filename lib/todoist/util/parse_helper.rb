require "ostruct"

module Todoist
  module Util
    class ParseHelper

      def self.utcOffsetHours
        return Time.now.utc_offset/60/60
      end

      def self.parseTodoistDate(item, key)
        if item[key]
          time = Time.parse(item[key])
          return time.to_datetime
        else
          return nil
        end
      end


      def self.filterToday(item, key)

        now = DateTime.now
        if parseTodoistDate(item, key) && parseTodoistDate(item, key) <= DateTime.new(now.year, now.month, now.day, -utcOffsetHours) + 1
          return true
        else 
          return false
        end
      end
      
      def self.formatTime(datetime)
        datetime.strftime("%Y-%m-%dT%H:%M")
      end

      def self.make_objects_as_array(objects_as_hashes, key = "id")
        objects = {}
        
        objects_as_hashes.each do |object_data|
            begin
              object = make_object(object_data)
              objects[object.send(key)] = object
            rescue
              # Occasionally the API returns arrays of arrays of hashes
              if object_data.kind_of? Array
                
                object = make_object(object_data[1])
                objects[object.send(key)] = object
              end
            end
        end
        return objects
      end
      
      def self.make_object(object_as_hash)
        json = object_as_hash.to_json
        object = JSON.parse(json, object_class: OpenStruct)
        return object
      end
      
    end
  end
end
