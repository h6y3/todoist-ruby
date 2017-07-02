require "ostruct"

module Todoist
  module Util
    class ParseHelper

      def self.utc_offset_hours
        return Time.now.utc_offset/60/60
      end

      def self.parse_todoist_date(item, key)
        if item[key]
          time = Time.parse(item[key])
          return time.to_datetime
        else
          return nil
        end
      end


      def self.filter_today(item, key)

        now = DateTime.now
        if parse_todoist_date(item, key) && parse_todoist_date(item, key) <= DateTime.new(now.year, now.month, now.day, -utc_offset_hours) + 1
          return true
        else 
          return false
        end
      end
      
      def self.format_time(datetime)
        datetime.strftime("%Y-%m-%dT%H:%M")
      end

      def self.make_objects_as_array(object_datas, key = "id")
        objects_as_array = []
        
        object_datas.each do |object_data|
            begin
              object = make_object(object_data)
              objects_as_array << object
            rescue
              # Occasionally the API returns arrays of arrays of hashes
              if object_data.kind_of? Array
                
                object = make_object(object_data[1])
                objects_as_array << object
              end
            end
        end
        return objects_as_array
      end

      def self.make_objects_as_hash(object_datas, key = "id")
        objects_as_hash = {}
        
        object_datas.each do |object_data|
            begin
              object = make_object(object_data)
              objects_as_hash[object.send(key)] = object
            rescue
              # Occasionally the API returns arrays of arrays of hashes
              if object_data.kind_of? Array
                
                object = make_object(object_data[1])
                objects_as_hash[object.send(key)] = object
              end
            end
        end
        return objects_as_hash
      end
      
      def self.make_object(object_as_hash)
        json = object_as_hash.to_json
        object = JSON.parse(json, object_class: OpenStruct)
        return object
      end
      
    end
  end
end
