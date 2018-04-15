require 'httparty'
require 'logger'

require 'resin/settings'
require 'resin/util'

module Resin
  class Request
    include HTTParty

    # logger ::Logger.new(STDOUT), :debug, :curl

    def initialize
      @settings = Settings.instance
      @options = {
          base_uri: @settings.get('api_endpoint'),
          timeout: @settings.get('timeout').to_i / 1000
      }
    end

    ##
    # Public: Enforce error raising depending on the status code of a request.
    #
    # req - The request that should get checked.
    #
    # Example:
    #
    #   handle_status_code successful_req
    #   # => nil
    #
    #   handle_status_code unauthorized_req
    #   # Net::HTTPUnauthorized ...
    def handle_status_code(req)
      case req.code
      when 200..204; return
      when 400; raise ResponseError.new req
      when 401; raise ResponseError.new req
      else raise StandardError
      end
    end

    ##
    # Public: Internal method for simple header generation for HTTP requests.
    #
    # auth - Boolean value that toggles if authentication should be included. (Bearer Token)
    # json -
    #
    # Example:
    #
    #   headers
    #   # => {}
    #
    #   headers json=true
    #   # => {}
    #
    def headers(auth=false, json=true)
      headers = {}
      headers['Authorization'] = "Bearer #{@settings.get('token')}" if auth
      headers['Content-Type'] = 'application/json' if json
      headers
    end

  end
end