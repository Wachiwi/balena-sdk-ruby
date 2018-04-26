require 'singleton'
require 'resin/request'
require 'json'

module Resin
  ##
  # This class represents all account based requests like `login`, `register` and `get_details`.
  #
  # Example
  #
  #   u = User.new
  #   # => #<Resin::User:0x007fc2658b1cb0 @settings=#<Resin::Settings:0x007fc2658b1c88 ...
  #
  #   u.login 'username', 'password'
  #   # => true
  #
  #   u.logged_in?
  #   # => true
  #
  class User < Request

    def initialize
      super()

      @user_details_cache = {}
    end

    ##
    # Login to Resin.io
    # If the login is successful, the token is persisted between sessions.
    #
    # username - The `username` that should be used for login
    # password - The `password` that belongs to the user that should be used for login
    #
    # Example
    #
    #   user.login(username, password)
    #   # => true
    #
    # Returns `true` if the login was successful otherwise it returns `false`.
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

    ##
    # Register to Resin.io
    #
    # email - The email of the user that should get logged in
    # password - The password of the user that should get logged in
    #
    # Example
    #
    #   user = User.new
    #
    #   user.register 'username', 'password'
    #   # => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...uYW1lIjoiYnJmemVpX2RrMnNkcnE5a2E0NjQiLCJlbWFp...'
    #
    # Returns the token if the registration was successful
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

    ##
    # Login to Resin.io with a token or api key
    # Login to resin with a session token or api key instead of with credentials.
    #
    # token - the auth token
    #
    # Example
    #
    #   user.login_with_token('W8ZvPSEZ6uzqgGA654uSc53FjJNohBar')
    #   # => true
    #
    # Returns `true` if the login was successful otherwise it returns `false`.
    def login_with_token(token)
      @settings.set(key: 'token', value: token)
    end

    ##
    # Logout from Resin.io
    #
    # Example
    #
    #   user.logout
    #   # => true
    #
    # Logs the current user
    def logout
      @settings.remove('token')
    end

    ##
    # Get the user details of the current
    #
    # Example
    #
    #   user.get_details
    #   # => {"id"=>3210, "username"=>"username", "email"=>"emaill@provider.tld"}
    #
    # Returns the object hash of the user that is currently logged in
    def get_details
      return @user_details_cache unless @user_details_cache.empty?
        
      opts = @options.merge({
        headers: headers(auth: true),
      })

      req = self.class.get '/user/v1/whoami', opts
      handle_status_code req
      @user_details_cache = JSON.parse(req.body)
    end

    ##
    # Get current logged in user's raw API key or session token
    #
    # Example
    #
    #   user.get_token
    #   # => nil
    #
    #   user.get_token
    #   # => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...uYW1lIjoiYnJmemVpX2RrMnNkcnE5a2E0NjQiLCJlbWFp...'
    #
    # Returns the token if its set otherwise it returns `nil`
    def get_token
      @settings.get 'token'
    end

    ##
    # Get current logged in user's id
    #
    # Example
    #
    #   user.get_id
    #   # => 3210
    #
    # Returns the ID of the current user
    def get_id
      get_details['id']
    end

    ##
    # Get current logged in user's email
    #
    # Example
    #
    #   user.get_email
    #   # => 'user@provider.tld'
    #
    # Returns the email of the current user
    def get_email
      get_details['email']
    end

    ##
    # Check if you're logged in
    #
    # Example
    #
    #   user = User.new
    #
    #   user.logged_in?
    #   # => false
    #
    # Returns `true` if the user is logged in otherwise it returns `false`.
    def logged_in?
      !@settings.get('token').nil?
    end

    ##
    # Creates a new user API key
    #
    # Example
    #
    #   user.create_api_key 'test'
    #   # => 'W8ZvPSEZ6uzqgGA654uSc53FjJNohBar'
    #
    # Returns the generated api key
    def create_api_key(name)
      opts = @options.merge({
        headers: headers(auth: true, json: true),
        body: JSON.generate({
          name: name
        })
      })

      req = self.class.post '/api-key/user/full', opts
      handle_status_code req
      JSON.parse(req.body)
    end
  end
end