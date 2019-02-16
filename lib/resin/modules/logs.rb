require 'resin/request'
require 'resin/modules/config'
require 'resin/modules/device'

module Resin::Modules
  class Logs < Resin::Request

    def initialize
      super()

    end

    def get_context(id)

    end

    def subscribe(id)
      opts = @options.merge({
        headers: headers(auth: true),
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
  end
end