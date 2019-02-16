require 'jwt'

module Resin
  class Util
    def self.get_api_key
      ENV['RESIN_API_KEY']
    end

    def self.should_update_token(token)
      begin
        JWT.decode token, nil, false
      rescue JWT::DecodeError, JWT::ExpiredSignature
        true
      end
    end

    def self.symbolize_keys(hash)
      hash.keys.each do |key|
        hash[(key.to_sym rescue key) || key] = hash.delete(key)
      end
    end
    
  end
end