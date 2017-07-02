require "net/http"
require "json"
require "todoist/util/config"
require 'net/http/post/multipart'
require 'mimemagic'

module Todoist
  module Util
    class NetworkHelper

      @last_request_time = 0.0

      def initialize(client)
        @client = client
        @command_cache = Concurrent::Array.new([])
        @command_mutex = Mutex.new
        @temp_id_callback_cache = Concurrent::Array.new([])
      end
      
      def configure_http(command)
        http = Net::HTTP.new(Config.getURI()[command].host, Config.getURI()[command].port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        return http
      end

      def configure_request(command, params)
        request = Net::HTTP::Post.new(Config.getURI()[command].request_uri)
        request.set_form_data(params)
        return request
      end
      
      # Files need to be of class UploadIO
      
      def get_multipart_response(command, params={})
        token = {token: @client.token}
        http = configure_http(command)
        url = Config.getURI()[command]
        http.start do
          req = Net::HTTP::Post::Multipart.new(url, token.merge(params))
          response = http.request(req)
          begin
            return JSON.parse(response.body)
          rescue JSON::ParserError
              return response.body
          end
        end
      end
    
      def get_response(command, params ={}, token = true)
        token = token ? {token: @client.token} : {}
        http = configure_http(command)
        request = configure_request(command, token.merge(params))
        retry_after_secs = Todoist::Util::Config.retry_time
        # Hack to fix encoding issues with Net:HTTP for login case
        request.body = request.body.gsub '%40', '@' unless token
        while true
          response = throttle_request(http, request)
          case response.code.to_i
          when 200 
            begin
              return JSON.parse(response.body)
            rescue JSON::ParserError
              return response.body
            end
          when 400
            raise StandardError, "HTTP 400 Error - The request was incorrect."
          when 401
            raise StandardError, "HTTP 401 Error - Authentication is required, and has failed, or has not yet been provided."
          when 403
            raise StandardError, "HTTP 403 Error - The request was valid, but for something that is forbidden."
          when 404
            raise StandardError, "HTTP 404 Error - The requested resource could not be found."
          when 429
            puts("Encountered 429 - retry after #{retry_after_secs}")
            sleep(retry_after_secs)
            retry_after_secs *= Todoist::Util::Config.retry_time
          when 500
            raise StandardError, "HTTP 500 Error - The request failed due to a server error."
          when 503
            raise StandardError, "HTTP 503 Error - The server is currently unable to handle the request."
          end
        end
        
      end
      
      def throttle_request(http, request)
        time_since_last_request = Time.now.to_f - @last_request_time
        
        if (time_since_last_request < Todoist::Util::Config.delay_between_requests)
          wait = Todoist::Util::Config.delay_between_requests - time_since_last_request
          puts("Throttling request by: #{wait}")
          sleep(wait)
        end
        @last_request_time = Time.now.to_f
        http.request(request)
      end
      
      # Prepares a file for multipart upload
      def multipart_file(file)
          filename = File.basename(file)
          mime_type = MimeMagic.by_path(filename).type
          return UploadIO.new(file, mime_type, filename)
      end
        
      def queue(command, callback = nil) 
        @command_mutex.synchronize do
          @command_cache.push(command)
          @temp_id_callback_cache.push(callback) if callback
        end
      end
      
      def sync
        @command_mutex.synchronize do    
          response = get_sync_response({commands: @@command_cache.to_json})
          @command_cache.clear
          # Process callbacks here
          temp_id_mappings = response["temp_id_mapping"]
          @temp_id_callback_cache.each do |callback| 
              callback.(temp_id_mappings)
          end
          @temp_id_callback_cache.clear
        end
      end

      def get_sync_response(params)
        get_response(Config::TODOIST_SYNC_COMMAND, params)
      end

    end
  end
end
