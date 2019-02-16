require 'resin/pine_request'

module Resin::Modules
  class Application < Resin::PineRequest
    def initialize
      super()
    end

    ##
    # Get all applications
    #
    # Example
    #
    #   app.get_all
    #
    # Returns a list that contains all info about all applications.
    def get_all
      opts = @options.merge(
        headers: headers(auth: true),
      )

      req = self.class.get '/application', opts
      handle_status_code req

      self.parse(req)['d']
    end
  end
end