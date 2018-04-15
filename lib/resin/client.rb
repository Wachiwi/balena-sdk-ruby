require 'httparty'

module Resin
  BASE_URL = 'https://api.resin.io/v1/'
  class Client
    include HTTParty

  end
end