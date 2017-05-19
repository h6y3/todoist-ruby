require "net/http"
require "json"
require "todoist/util/config"
require 'net/http/post/multipart'
require 'mimemagic'

module Todoist
  module Util
    class NetworkHelper

      @@last_request_time = 0.0
      
      def self.configureHTTP(command)
        http = Net::HTTP.new(Config.getURI()[command].host, Config.getURI()[command].port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        return http
      end

      def self.configureRequest(command, params)
        request = Net::HTTP::Post.new(Config.getURI()[command].request_uri)
        request.set_form_data(params)
        return request
      end
      
      # Files need to be of class UploadIO
      
      def self.getMultipartResponse(command, params={})
        token = {token: Todoist::Util::Config.token}
        http = configureHTTP(command)
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
    
      def self.getResponse(command, params ={}, token = true)
        token = token ? {token: Todoist::Util::Config.token} : {}
        http = configureHTTP(command)
        request = configureRequest(command, token.merge(params))
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
      
      def self.throttle_request(http, request)
        time_since_last_request = Time.now.to_f - @@last_request_time
        
        if (time_since_last_request < Todoist::Util::Config.delay_between_requests)
          wait = Todoist::Util::Config.delay_between_requests - time_since_last_request
          puts("Throttling request by: #{wait}")
          sleep(wait)
        end
        @@last_request_time = Time.now.to_f
        http.request(request)
      end
      
      # Prepares a file for multipart upload
      def self.multipart_file(file)
          filename = File.basename(file)
          mime_type = MimeMagic.by_path(filename).type
          return UploadIO.new(file, mime_type, filename)
      end
    end
  end
end
