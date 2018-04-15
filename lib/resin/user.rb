require 'singleton'
require 'resin/request'
require 'json'

module Resin
  class User < Request

    def initialize
      super()

      @user_details_cache = {}
    end

    def login(username, password)
      opts = @options.merge({
        headers: headers,
        body: JSON.generate({
          username: username,
          password: password
        })
      })

      req = self.class.post '/login_', opts
      handle_status_code req
      token = req.body
      @settings.set(key: 'token', value: token)
    end

    def register(email, password)
      opts = @options.merge({
        headers: headers,
        body: JSON.generate({
          email: email,
          password: password
        })
      })

      req = self.class.post '/user/register', opts
      handle_status_code req
      token = req.body
      @settings.set(key: 'token', value: token)
    end

    def login_with_token(token)
      @settings.set(key: 'token', value: token)
    end

    def get_user_details
      return @user_details_cache unless @user_details_cache.empty?
        
      opts = @options.merge({
        headers: headers,
      })

      req = self.class.get '/user/v1/whoami', opts
      handle_status_code req
      token = req.body
      @settings.set(key: 'token', value: token)
    end

    def get_token()

    end

    def logged_in?
      !@settings.get('token').nil?
    end

    def create_api_key(name)

    end
  end
end