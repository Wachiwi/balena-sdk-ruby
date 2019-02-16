require 'singleton'

require 'resin/modules'
require 'resin/settings'
require 'resin/exceptions'
require 'resin/version'

module Resin
  class Resin
    require 'singleton'

    def initialize
      @user = Modules::User.new
      @is_configured = false
    end

    def configure(username: nil, password: nil, token: nil)
      if token.nil? and (!username.nil? and !password.nil?)
        # Username and password is set
        resin = Resin.instance

      elsif !token.nil? and (username.nil? and password.nil?)
        # Token is set
        resin = Resin.instance

      else
        # Both or none is set
        raise InvalidConfigurationError
      end
    end

    def get_user_details
      @user.get_details
    end
  end

  def configure(username: nil, password: nil, token: nil)
    Resin.instance.configure username, password, token
  end
end
