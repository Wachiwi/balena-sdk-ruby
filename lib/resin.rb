require 'resin/user'
require 'resin/settings'
require 'resin/version'

module Resin

  def whoami
    User.get_user_det
  end
  
  
  
end
